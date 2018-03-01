module RoutesHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods

    def _approvable_time_entries_path(project, issue, *args)
      # if issue
      #   issue_time_entries_path(issue, *args)
      # elsif project    
      if project
        project_approvable_time_entries_path(project, *args)
      else
        approvable_time_entries_path(*args)
      end
    end

    def _report_approvable_time_entries_path(project, issue, *args)
      # if issue
      #   report_issue_time_entries_path(issue, *args)
      # elsif project
      if project
        report_project_approvable_time_entries_path(project, *args)
      else
        report_approvable_time_entries_path(*args)
      end
    end
  end
end

# Add module to RoutesHelper
RoutesHelper.send(:include, RoutesHelperPatch)