class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  before_action { redirect_to root_path if authenticated? }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for(@user)
      redirect_to after_authentication_url
    else
      render :new, status: :unprocessable_entity
      flash.now[:alert] = "Please check your email address and password."
    end
  end

  private

  def user_params
    params.expect(user: [ :full_name, :email_address, :password, :password_confirmation ])
  end
end
