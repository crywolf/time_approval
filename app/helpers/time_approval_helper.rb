module TimeApprovalHelper
  include ApplicationHelper

  def can_user_approve_own_entries?
    User.current.admin? || Setting.plugin_time_approval['approve_own_time_entries']
  end

  def approvable_by_current_user?(time_entry)
    return true if User.current.admin?

    is_project_member = User.current.membership(time_entry.project)

    if Setting.plugin_time_approval['approve_own_time_entries']
      is_project_member
    else
      is_project_member && time_entry.user != User.current
    end
  end

  def format_approved_field(time_entry)
    approved = time_entry['approved']
    return '-' if approved.nil?

    value = approved ? l(:approved) : l(:rejected)

    approved_at_str = ' (' << format_object(time_entry['approved_at'].to_date) << ')'

    output = format_object(value) << approved_at_str
    output = '-' unless output.present?

    output
  end
end
