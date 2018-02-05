Redmine::Plugin.register :time_approval do
  name 'Time Approval plugin'
  author 'Vojtěch Toman'
  description 'This plugin allows managers to approve time spent by developers'
  version '0.0.1'

  permission :approvable_time_entries, { approvable_time_entries: [:index, :bulk_approve] }
  menu :project_menu, :approvable_time_entries, { controller: 'approvable_time_entries', action: 'index' }, after: :activity, param: :project_id
end
