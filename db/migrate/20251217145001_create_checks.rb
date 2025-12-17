class CreateChecks < ActiveRecord::Migration[8.0]
  def change
    create_table :checks do |t|
      t.references :monitor, null: false, foreign_key: { to_table: :monitors }
      t.integer :status_code
      t.integer :response_time_ms
      t.boolean :success
      t.timestamps
    end
  end
end
