class ApprovableTimeEntriesController < ApplicationController

  before_filter :find_time_entries, :only => [:bulk_approve]
  before_filter :authorize, :only => [:bulk_approve]

  before_filter :find_optional_project, :only => [:index, :report]
  before_filter :authorize_global, :only => [:index, :report]

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :sort
  include SortHelper
  helper :issues
  include TimelogHelper
  helper :timelog
  include TimeApprovalHelper
  helper :time_approval
  helper :custom_fields
  include CustomFieldsHelper
  helper :queries
  include QueriesHelper
  helper :routes

  def index
    set_params_for_default_filters

    @query = ApprovableTimeEntryQuery.build_from_params(params, :project => @project, :name => '_')

    sort_init(@query.sort_criteria.empty? ? [['spent_on', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    scope = time_entry_scope(:order => sort_clause).
      includes(:project, :user, :issue).
      preload(:issue => [:project, :tracker, :status, :assigned_to, :priority])

    if !can_user_approve_own_entries?
      scope = scope.where.not(user: User.current)
    end

    respond_to do |format|
      format.html {
        @entry_count = scope.count
        @entry_pages = Paginator.new @entry_count, per_page_option, params['page']
        @entries = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).to_a
        @total_hours = scope.sum(:hours).to_f

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

  def report
    @query = ApprovableTimeEntryQuery.build_from_params(params, :project => @project, :name => '_')
    scope = time_entry_scope

    @report = TimeApproval::Helpers::TimeReport.new(@project, @issue, params[:criteria], params[:columns], scope)

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.csv  { send_data(report_to_csv(@report), :type => 'text/csv; header=present', :filename => 'timelog.csv') }
    end
  end

  def bulk_approve
    if params[:reject]
      message_sym = :notice_successful_reject
    else
      message_sym = :notice_successful_approve
    end

    unsaved_time_entry_ids = []
    @time_entries.each do |time_entry|
      time_entry.reload

      if params[:reject]
        time_entry.approved = false
      else
        time_entry.approved = true
      end

      time_entry.approved_by = User.current
      time_entry.approved_at = DateTime.now
      time_entry.approved_comment = params[:approved_comment][time_entry.id.to_s]

      unless time_entry.save
        logger.info "time entry could not be saved: #{time_entry.errors.full_messages}" if logger && logger.info?
        # Keep unsaved time_entry ids to display them in flash error
        unsaved_time_entry_ids << time_entry.id
      end
    end
    set_flash_from_bulk_time_entry_action(message_sym, @time_entries, unsaved_time_entry_ids)
    redirect_back_or_default approvable_time_entries_path
  end


private
  def set_params_for_default_filters
    params[:f] = ['spent_on', 'approved'] unless params[:f]

    spent_on_setting = Setting.plugin_time_approval['spent_on_filter_value']
    params[:op] = { spent_on: spent_on_setting, approved: '!*' } unless params[:op]
  end

  # Returns the TimeEntry scope for index and report actions
  def time_entry_scope(options={})
    scope = @query.results_scope(options)
    if @issue
      scope = scope.on_issue(@issue)
    end
    scope
  end

  def set_flash_from_bulk_time_entry_action(message_sym, time_entries, unsaved_time_entry_ids)
    if unsaved_time_entry_ids.empty?
      flash[:notice] = l(message_sym) unless time_entries.empty?
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
    raise Unauthorized unless @time_entries.all? {|t| approvable_by_current_user?(t)}
    @projects = @time_entries.collect(&:project).compact.uniq
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
    redirect_back_or_default approvable_time_entries_path
  end

end
