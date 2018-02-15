class AddApprovedAtToTimeEntries < ActiveRecord::Migration
  def change
    add_column :time_entries, :approved_at, :datetime
  end
end