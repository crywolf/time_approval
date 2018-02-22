class ApprovableTimeEntriesController < ApplicationController

  before_filter :find_time_entries, :only => [:bulk_approve]
  before_filter :authorize, :only => [:bulk_approve]

  before_filter :find_optional_project, :only => [:index]
  before_filter :authorize_global, :only => [:index]

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :sort
  include SortHelper
  helper :issues
  include TimelogHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :queries
  include QueriesHelper

  def index
    set_params_for_default_filters

    @query = ApprovableTimeEntryQuery.build_from_params(params, :project => @project, :name => '_')

    sort_init(@query.sort_criteria.empty? ? [['spent_on', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    scope = time_entry_scope(:order => sort_clause).
      includes(:project, :user, :issue).
      preload(:issue => [:project, :tracker, :status, :assigned_to, :priority])

    respond_to do |format|
      format.html {
        @entry_count = scope.to_a.reject {|t| !approvable_by_current_user(t)}.count

        @entry_pages = Paginator.new @entry_count, per_page_option, params['page']
        @entries = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).to_a
        @entries.reject! {|t| !approvable_by_current_user(t)}

        render :layout => !request.xhr?
      }
      format.api  {
        @entry_count = scope.count
        @offset, @limit = api_offset_and_limit
        @entries = scope.offset(@offset).limit(@limit).preload(:custom_values => :custom_field).to_a
      }
      format.atom {
        entries = scope.limit(Setting.feeds_limit.to_i).reorder("#{TimeEntry.table_name}.created_on DESC").to_a
        render_feed(entries, :title => l(:label_spent_time))
      }
      format.csv {
        # Export all entries
        @entries = scope.to_a
        send_data(query_to_csv(@entries, @query, params), :type => 'text/csv; header=present', :filename => 'timelog.csv')
      }
    end
  end

  def bulk_approve
    unsaved_time_entry_ids = []
    @time_entries.each do |time_entry|
      time_entry.reload
      next if time_entry.approved 
      time_entry.approved = true
      time_entry.approved_by = User.current
      time_entry.approved_at = DateTime.now
      unless time_entry.save
        logger.info "time entry could not be approved: #{time_entry.errors.full_messages}" if logger && logger.info?
        # Keep unsaved time_entry ids to display them in flash error
        unsaved_time_entry_ids << time_entry.id
      end
    end
    set_flash_from_bulk_time_entry_approved(@time_entries, unsaved_time_entry_ids)
    redirect_back_or_default :index
  end


private
  def set_params_for_default_filters
    params[:f] = ['spent_on', 'approved'] unless params[:f]

    spent_on_setting = Setting.plugin_time_approval['spent_on_filter_value']
    params[:op] = { spent_on: spent_on_setting, approved: '=' } unless params[:op]

    params[:v] = { approved: ['false'] } unless params[:v]
  end

  def approvable_by_current_user(time_entry)
    return true if User.current.admin?

    is_project_member = User.current.membership(time_entry.project)

    if (Setting.plugin_time_approval['approve_own_time_entries'])
      is_project_member
    else
      is_project_member && time_entry.user != User.current
    end
  end

  # Returns the TimeEntry scope for index and report actions
  def time_entry_scope(options={})
    scope = @query.results_scope(options)
    if @issue
      scope = scope.on_issue(@issue)
    end
    scope
  end

  def set_flash_from_bulk_time_entry_approved(time_entries, unsaved_time_entry_ids)
    if unsaved_time_entry_ids.empty?
      flash[:notice] = l(:notice_successful_approve) unless time_entries.empty?
    else
      flash[:error] = l(:notice_failed_to_save_time_entries,
                        :count => unsaved_time_entry_ids.size,
                        :total => time_entries.size,
                        :ids => '#' + unsaved_time_entry_ids.join(', #'))
    end
  end

  def find_optional_project
    if params[:issue_id].present?
      @issue = Issue.find(params[:issue_id])
      @project = @issue.project
    elsif params[:project_id].present?
      @project = Project.find(params[:project_id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_time_entries
    @time_entries = TimeEntry.where(:id => params[:id] || params[:ids]).
      preload(:project => :time_entry_activities).
      preload(:user).to_a

    raise ActiveRecord::RecordNotFound if @time_entries.empty?
    raise Unauthorized unless @time_entries.all? {|t| approvable_by_current_user(t)}
    @projects = @time_entries.collect(&:project).compact.uniq
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
    redirect_back_or_default :index
  end

end
