require 'time_entry_query_patch'
require 'time_entry_patch'
require 'timelog_controller_patch'
require 'queries_helper_patch'
require 'timelog_helper_patch'
require 'routes_helper_patch'
require 'helpers/time_report'

Redmine::Plugin.register :time_approval do
  name 'Time Approval plugin'
  author 'Vojtěch Toman'
  description 'This plugin allows managers to approve time spent by developers'
  version '0.0.1'

  permission :approvable_time_entries, { approvable_time_entries: [:index, :report, :bulk_approve] }, require: :loggedin

  menu :application_menu, :approvable_time_entries, { controller: 'approvable_time_entries', action: 'index' }, if: (Proc.new { User.current.allowed_to?(:approvable_time_entries, nil, global: true) })
  menu :project_menu, :approvable_time_entries, { controller: 'approvable_time_entries', action: 'index' }, after: :activity, param: :project_id

  settings default: { 'spent_on_filter_value' => 'lw', 'approve_own_time_entries' => 'true' }, partial: 'settings/time_approval_settings'
end
