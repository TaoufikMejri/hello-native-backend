class ApplicationController < ActionController::API
  private

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end

  def current_user
    @current_user ||= user_from_token
  end

  def user_from_token
    token = request.headers["Authorization"]&.split(" ")&.last
    return nil unless token

    payload = JsonWebToken.decode(token)
    User.find_by(id: payload[:user_id]) if payload
  end
end
