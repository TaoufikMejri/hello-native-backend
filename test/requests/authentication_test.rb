require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "signup creates a user and returns a token" do
    assert_difference("User.count", 1) do
      post "/signup", params: { name: "Ada Lovelace", email: "ada@example.com", password: "secret123" }
    end

    assert_response :created
    body = response.parsed_body
    assert body["token"].present?
    assert_equal "ada@example.com", body["user"]["email"]
  end

  test "signup rejects invalid params" do
    assert_no_difference("User.count") do
      post "/signup", params: { name: "", email: "not-an-email", password: "short" }
    end

    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].present?
  end

  test "signup rejects duplicate email" do
    post "/signup", params: { name: "Dup", email: users(:one).email, password: "secret123" }

    assert_response :unprocessable_entity
  end

  test "login succeeds with correct credentials" do
    post "/login", params: { email: users(:one).email, password: "password" }

    assert_response :success
    body = response.parsed_body
    assert body["token"].present?
    assert_equal users(:one).id, body["user"]["id"]
  end

  test "login fails with wrong password" do
    post "/login", params: { email: users(:one).email, password: "wrong" }

    assert_response :unauthorized
  end

  test "me requires a valid token" do
    get "/me"
    assert_response :unauthorized

    post "/login", params: { email: users(:one).email, password: "password" }
    token = response.parsed_body["token"]

    get "/me", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    assert_equal users(:one).email, response.parsed_body["email"]
  end
end
