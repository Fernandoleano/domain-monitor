class NotificationsController < ApplicationController
  before_action :set_notification, only: [:mark_as_read]

  def mark_as_read
    @notification.update(read_at: Time.current)
    
    # Broadcast the count update (Turbo Stream)
    # The count in the navbar (bell) will decrement automatically via this broadcast
    # Logic is likely in the Notification model callback we added earlier
    
    if @notification.url.present?
      redirect_to @notification.url, allow_other_host: true
    else
      redirect_back fallback_location: root_path
    end
  end
  
  private
    def set_notification
      @notification = Current.user.notifications.find(params[:id])
    end
end
