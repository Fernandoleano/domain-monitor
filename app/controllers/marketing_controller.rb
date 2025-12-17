class MarketingController < ApplicationController
    # allow unauthenticated users to access the index action
    allow_unauthenticated_access

  def index
    redirect_to sites_path if authenticated?
  end
end
