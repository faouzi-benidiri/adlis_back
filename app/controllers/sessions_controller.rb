class SessionsController < ApplicationController
  skip_before_action :authenticate, only: :create
  before_action :set_session, only: %i[show destroy]

  # Returns the list of sessions for the current user
  def index
    render json: Current.user.sessions.order(created_at: :desc)
  end

  # Retrieves data for the current user
  def show
    user = Current.user
    render json: { email: user.email, username: user.username, user_id: user.id, session_id: @session.id }
  end

  # Creates a new session for the user
  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      @session = user.sessions.create!(expires_at: 3.hours.from_now)
      token = @session.signed_id

      render json: { token: token, session_id: @session.id, user_id: user.id }, status: :created
    else
      render json: { error: "That email or password is incorrect" }, status: :unauthorized
    end
  end

  # Destroys an existing session
  def destroy
    @session.destroy
    render json: { message: "Session successfully destroyed" }
  end

  private
    # Retrieves the session for the current user
    def set_session
      @session = Current.user.sessions.find(params[:id])
    end
end
