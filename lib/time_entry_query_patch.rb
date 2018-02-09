module TimeEntryQueryPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :initialize_available_filters, :field_approved
    end

  end

  module InstanceMethods
    def initialize_available_filters_with_field_approved
      initialize_available_filters_without_field_approved
      add_available_filter "approved", type: :list, values: [[l('general_text_No'), "false"], [l('general_text_Yes'), "true"]]
    end
  end
end

# Add module to TimeEntryQuery
TimeEntryQuery.send(:include, TimeEntryQueryPatch)