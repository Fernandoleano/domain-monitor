class CreateMonitors < ActiveRecord::Migration[8.0]
  def change
    create_table :monitors do |t|
      t.references :user, null: false, foreign_key: true
      t.string :url, null: false
      t.string :name
      t.integer :check_interval, default: 15
      t.string :status, default: "pending"
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
