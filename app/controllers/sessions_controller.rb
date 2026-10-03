class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email]&.strip&.downcase)

    if user&.authenticate(params[:password])
      render json: { token: JsonWebToken.encode({ user_id: user.id }), user: user_json(user) }, status: :ok
    else
      render json: { errors: [ "Invalid email or password" ] }, status: :unauthorized
    end
  end

  private

  def user_json(user)
    { id: user.id, name: user.name, email: user.email }
  end
end
