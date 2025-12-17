class AddDetailsToNotifications < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :title, :string
    add_column :notifications, :body, :text
    add_column :notifications, :url, :string
  end
end
