module TimeEntryPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def approved_by
      User.where(id: self.approved_by_user_id).first
    end
  end
end

# Add module to TimeEntry
TimeEntry.send(:include, TimeEntryPatch)