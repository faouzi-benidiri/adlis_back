class Identity::EmailVerificationsController < ApplicationController
  skip_before_action :authenticate, only: :show

  before_action :set_user, only: :show

  # Display the email verification action
  def show
    if @user.update(verified: true)
      render json: { status: 'success', message: 'Your email has been successfully verified.' }
    else
      render json: { status: 'failure', error: 'An error occurred while verifying the email.' }
    end
  end

  # Send the verification email to the current user
  def create
    UserMailer.with(user: Current.user).email_verification.deliver_later
  end

  private
    # Get the user associated with the email verification token
    def set_user
      token = EmailVerificationToken.find_signed!(params[:sid]) 
      @user = token.user 
    rescue StandardError
      render json: { error: "That email verification link is invalid" }, status: :bad_request
    end
end
