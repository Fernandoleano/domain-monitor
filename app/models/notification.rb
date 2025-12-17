class Notification < ApplicationRecord
  belongs_to :user

  after_create_commit -> { broadcast_prepend_later_to [ user, "notifications" ], target: "notifications_list" }
  after_create_commit -> { broadcast_replace_later_to [ user, "notifications_bell" ], target: "notification_bell", partial: "application/notification_bell", locals: { user: user } }
end
