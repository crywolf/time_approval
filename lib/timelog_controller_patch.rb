module TimelogControllerPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :update, :check_if_approved
    end

  end

  module InstanceMethods
    def update_with_check_if_approved
      if @time_entry.approved
        render_403
        return false
      end
      update_without_check_if_approved
    end
  end
end

# Add module to TimelogController
TimelogController.send(:include, TimelogControllerPatch)