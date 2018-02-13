module TimeEntryPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      belongs_to :approved_by, class_name: 'User', foreign_key: 'approved_by_user_id'
    end
  end
end

# Add module to TimeEntry
TimeEntry.send(:include, TimeEntryPatch)