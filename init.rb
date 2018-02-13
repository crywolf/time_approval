require 'time_entry_query_patch'
require 'time_entry_patch'
require 'timelog_controller_patch'

Redmine::Plugin.register :time_approval do
  name 'Time Approval plugin'
  author 'Vojtěch Toman'
  description 'This plugin allows managers to approve time spent by developers'
  version '0.0.1'

  permission :approvable_time_entries, { approvable_time_entries: [:index, :bulk_approve] }, require: :loggedin

  menu :application_menu, :approvable_time_entries, { controller: 'approvable_time_entries', action: 'index' }, if: (Proc.new { User.current.allowed_to?(:approvable_time_entries, nil, global: true) })
  menu :project_menu, :approvable_time_entries, { controller: 'approvable_time_entries', action: 'index' }, after: :activity, param: :project_id
end
