class CreateDailyAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_assignments do |t|
      t.date :date
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :question, null: false, foreign_key: true

      t.timestamps
    end

    add_index :daily_assignments, :date, unique: true
    add_index :daily_assignments, [ :recipient_id, :question_id ], unique: true
  end
end
