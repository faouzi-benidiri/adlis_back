class Identity::EmailsController < ApplicationController
  before_action :set_user

  # Update the user's email address
  def update
    if @user.update(email: params[:email])
      render_show # Call the method to display the user's details
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
    # Get the current user
    def set_user
      @user = Current.user
    end

    # Render the response to display the user's details
    def render_show
      if @user.email_previously_changed?
        resend_email_verification
        render(json: @user)
      else
        render json: @user
      end
    end

    # Resend the email verification to the user
    def resend_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end
end
