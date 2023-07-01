class Identity::EmailVerificationsController < ApplicationController
  skip_before_action :authenticate, only: :show

  before_action :set_user, only: :show

  # Affiche l'action de vérification de l'e-mail
  def show
    if @user.update(verified: true)
      render json: { status: 'success', message: 'Votre e-mail a été vérifié avec succès.' }
    else
      render json: { status: 'failure', error: 'Une erreur s\'est produite lors de la vérification de l\'e-mail.' }
    end
  end

  # Envoie l'e-mail de vérification à l'utilisateur actuel
  def create
    UserMailer.with(user: Current.user).email_verification.deliver_later
  end

  private
    # Récupère l'utilisateur associé au jeton de vérification d'e-mail
    def set_user
      token = EmailVerificationToken.find_signed!(params[:sid]) 
      @user = token.user 
    rescue StandardError
      render json: { error: "That email verification link is invalid" }, status: :bad_request
    end
end
