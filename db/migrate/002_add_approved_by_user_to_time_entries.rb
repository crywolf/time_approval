class AddApprovedByUserToTimeEntries < ActiveRecord::Migration
  def change
    add_column :time_entries, :approved_by_user_id, :integer, index: true
  end
end