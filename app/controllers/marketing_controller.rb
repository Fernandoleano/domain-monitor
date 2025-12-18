class MarketingController < ApplicationController
    # allow unauthenticated users to access the index action
    allow_unauthenticated_access
    layout "marketing"

  def index
    redirect_to sites_path if authenticated?
  end
end
