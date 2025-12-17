class AddCompositeIndexToChecks < ActiveRecord::Migration[8.1]
  def change
    add_index :checks, [ :site_id, :created_at ]
  end
end
