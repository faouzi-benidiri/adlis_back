class RegistrationsController < ApplicationController
  before_action :authenticate, except: :create

  # Create a new user
  def create
    @user = User.new(user_params)
  
    existing_user = User.find_by(email: @user.email)
  
    if existing_user
      render json: { error: "User already exists" }, status: :unprocessable_entity
    elsif @user.save
      @session = @user.sessions.create!(expires_at: 3.hours.from_now)
      token = response.set_header "token", @session.signed_id
      send_email_verification
      render json: { token: token, user_id: @user.id, session_id: @session.id }, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
  
  # Update the current user's information
  def update
    if Current.user.update(user_params_update)
      render json: Current.user
    else
      render json: Current.user.errors, status: :unprocessable_entity
    end
  end

  # Destroy the current user
  def destroy
    user = Current.user
  
    if user.destroy
      # Delete other data associated with the user
      BookReview.where(user_id: user.id).destroy_all
      BookUserRelation.where(user_id: user.id).destroy_all
  
      render json: { message: "User and associated data successfully destroyed" }
    else
      render json: { error: "Failed to destroy user" }, status: :unprocessable_entity
    end
  end

  private
    # Define the allowed parameters for updating the current user
    def user_params_update
      params.permit(:username)
    end
    
    # Define the allowed parameters for creating a user
    def user_params
      params.permit(:username, :email, :password, :password_confirmation)
    end

    # Send email verification to the user
    def send_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end
end
