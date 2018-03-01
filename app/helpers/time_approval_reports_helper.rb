module TimeApprovalReportsHelper
  include ApplicationHelper

  def format_hour_row(time_entry)
    approved = time_entry['approved']
    approved_at_str = approved ? ' (' << I18n::l(time_entry['approved_at'], format: "%e.%_m.%Y") << ')' : ''
    approved_str = format_object(approved) << approved_at_str
    approved_str = '-' unless approved_str.present?

   "pr:#{time_entry['project']}; i:#{time_entry['issue']}; dat: #{format_object(time_entry['spent_on'])} comment:#{format_object(time_entry['comments'])} h:#{format_object(time_entry['hours'])} #{l(:field_approved)}:#{approved_str}<br />".html_safe
  end
end
