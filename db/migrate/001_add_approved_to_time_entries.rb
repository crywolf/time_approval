class AddApprovedToTimeEntries < ActiveRecord::Migration
  def change
    add_column :time_entries, :approved, :boolean, default: false, index: true
  end
end