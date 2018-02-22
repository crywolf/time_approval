module TimeEntryQueryPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :initialize_available_filters, :field_approved

      # preload descendant
      require File.expand_path(File.join(File.dirname(__FILE__), '../app/models/approvable_time_entry_query.rb'))
      Module.const_get('ApprovableTimeEntryQuery')
    end
  end

  module InstanceMethods
    def initialize_available_filters_with_field_approved
      initialize_available_filters_without_field_approved
      add_available_filter "issue_id", type: :integer, label: :label_issue
      add_available_filter "approved", type: :list_optional, values: [[l('general_text_No'), "false"], [l('general_text_Yes'), "true"]]
    end
  end
end

# Add module to TimeEntryQuery
TimeEntryQuery.send(:include, TimeEntryQueryPatch)