class Identity::PasswordResetsController < ApplicationController
  skip_before_action :authenticate

  before_action :set_user, only: :update

  # Display the password reset form (no content)
  def edit
    head(:nocontent)
  end

  # Create a password reset request
  def create
    if @user = User.find_by(email: params[:email], verified: true)
      UserMailer.with(user: @user).password_reset.deliver_later
    else
      render json: { error: "You can't reset your password until you verify your email" }, status: :bad_request
    end
  end

  # Update the user's password
  def update
    if @user.update(user_params)
      revoke_tokens
      render(json: @user)
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
    # Set the user based on the password reset token
    def set_user
      token = PasswordResetToken.find_signed!(params[:sid])
      @user = token.user
    rescue StandardError
      render json: { error: "That password reset link is invalid" }, status: :bad_request
    end

    # Get the allowed user parameters for updating the password
    def user_params
      params.permit(:password, :password_confirmation)
    end

    # Revoke all password reset tokens for the user
    def revoke_tokens
      @user.password_reset_tokens.delete_all
    end
end
