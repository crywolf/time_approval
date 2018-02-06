module TimelogControllerPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :update, :check_if_approved
      alias_method_chain :bulk_update, :check_if_approved
    end

  end

  module InstanceMethods
    def update_with_check_if_approved
      raise Unauthorized if @time_entry.approved?
      update_without_check_if_approved
    end

    def bulk_update_with_check_if_approved
      raise Unauthorized if @time_entries.any? {|t| t.approved?}
      bulk_update_without_check_if_approved
    end
  end
end

# Add module to TimelogController
TimelogController.send(:include, TimelogControllerPatch)