class AddApprovedCommentToTimeEntries < ActiveRecord::Migration
  def change
    add_column :time_entries, :approved_comment, :string, limit: 1024, default: "", null: false
  end
end