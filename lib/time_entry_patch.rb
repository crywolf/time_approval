module TimeEntryPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      belongs_to :approved_by, class_name: 'User', foreign_key: 'approved_by_user_id'

      # preload descendant
      require File.join(File.dirname(__FILE__), '../app/models/approvable_time_entry.rb')
      Module.const_get('ApprovableTimeEntry')

      require File.join(File.dirname(__FILE__), '../app/models/approvable_time_entry_query.rb')
      Module.const_get('ApprovableTimeEntryQuery')
    end
  end
end

# Add module to TimeEntry
TimeEntry.send(:include, TimeEntryPatch)