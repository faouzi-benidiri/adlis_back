class RegistrationsController < ApplicationController
  before_action :authenticate, except: :create

  # Crée un nouvel utilisateur
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
  
  

    # Met à jour les informations de l'utilisateur actuel
    def update
      if Current.user.update(user_params_update)
        render json: Current.user
      else
        render json: Current.user.errors, status: :unprocessable_entity
      end
    end

  # Détruit l'utilisateur actuel
  def destroy
    user = Current.user
  
    if user.destroy
      # Supprimer les autres données associées à l'utilisateur
      BookReview.where(user_id: user.id).destroy_all
      BookUserRelation.where(user_id: user.id).destroy_all
  
      render json: { message: "User and associated data successfully destroyed" }
    else
      render json: { error: "Failed to destroy user" }, status: :unprocessable_entity
    end
  end

  private
    # Définit les paramètres acceptés pour la modification de l'utilisateur actuel 
    def user_params_update
      params.permit(:username)
    end
    # Définit les paramètres acceptés pour la création d'un utilisateur
    def user_params
      params.permit(:username, :email, :password, :password_confirmation)
    end
 
    # Envoie l'e-mail de vérification à l'utilisateur
    def send_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end
end
