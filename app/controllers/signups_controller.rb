class SignupsController < ApplicationController
  def create
    user = User.new(signup_params)

    if user.save
      render json: { token: JsonWebToken.encode({ user_id: user.id }), user: user_json(user) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def signup_params
    params.permit(:name, :email, :password)
  end

  def user_json(user)
    { id: user.id, name: user.name, email: user.email }
  end
end
