class SessionsController < ApplicationController
  skip_before_action :authenticate, only: :create
  before_action :set_session, only: %i[ show destroy ]

  # Renvoie la liste des sessions de l'utilisateur actuel
  def index
    render json: Current.user.sessions.order(created_at: :desc)
  end

  # Recupere les données de l'utilisateur actuel
  def show
    user = Current.user
      render json: { email: user.email, username: user.username, user_id: user.id, session_id: @session.id }
  end
  
  
  # Crée une nouvelle session pour l'utilisateur
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
  
  
  # Détruit une session existante
  def destroy
    @session.destroy
    render json: { message: "Session successfully destroyed" }
  end
  
  private
    # Récupère la session de l'utilisateur actuel
    def set_session
      @session = Current.user.sessions.find(params[:id])
    end
end
