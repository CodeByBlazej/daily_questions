class MakeAssignmentsTurnBased < ActiveRecord::Migration[8.0]
  def change
    # remove "daily" concept
    remove_index :daily_assignments, :date if index_exists?(:daily_assignments, :date)
    remove_column :daily_assignments, :date, :date if column_exists?(:daily_assignments, :date)

    add_column :daily_assignments, :assigned_at, :datetime
    add_column :daily_assignments, :answered_at, :datetime
    add_index  :daily_assignments, :answered_at

    # backfill assigned_at for existing rows (safe even if table is empty)
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE daily_assignments
          SET assigned_at = created_at
          WHERE assigned_at IS NULL
        SQL
      end
    end

    change_column_null :daily_assignments, :assigned_at, false
  end
end
