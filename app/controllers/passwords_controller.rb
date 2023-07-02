class PasswordsController < ApplicationController
  before_action :set_user

  # Update the user's password
  def update
    if !@user.authenticate(params[:current_password])
      render json: { error: "The current password you entered is incorrect" }, status: :bad_request
    elsif @user.update(user_params)
      @user.sessions.delete_all
      render json: { message: "User updated successfully" }, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
    # Set the current user
    def set_user
      @user = Current.user
    end

    # Define the allowed user parameters for password update
    def user_params
      params.permit(:password, :password_confirmation)
    end
end
