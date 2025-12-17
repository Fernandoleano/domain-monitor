class RenameMonitorsToSites < ActiveRecord::Migration[8.0]
  def change
    rename_table :monitors, :sites
    rename_column :checks, :monitor_id, :site_id
  end
end
