class ChangeColumnApprovedToInTimeEntries < ActiveRecord::Migration
  def up
    change_column_null :time_entries, :approved, true
    change_column_default :time_entries, :approved, nil

    execute <<-SQL
      UPDATE time_entries
        SET approved = NULL
        WHERE approved = FALSE;
    SQL
  end
 
  def down
    execute <<-SQL
      UPDATE time_entries
        SET approved = FALSE, approved_by_user_id = NULL, approved_at = NULL
        WHERE approved IS NULL;
    SQL

    change_column_null :time_entries, :approved, false
    change_column_default :time_entries, :approved, false
  end
end