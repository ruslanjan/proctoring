defmodule ProctoringWeb.AuthController do
  use ProctoringWeb, :controller
  import Plug.Conn

  alias Proctoring.Auth

  def login(conn, %{"username" => username, "password" => password}) do
    case Auth.login(username, password) do
      {:ok, token, user} ->
        render(conn, "login.json", token: token, user: user)
      {:error, :bad_credentials} ->
        conn
        |> send_resp(422, "bad_credentials")
    end
  end

  def refresh_token(conn, %{"token" => token}) do
    case Auth.refresh_user_auth_token(token) do
      {:ok, token, user} ->
        render(conn, "login.json", token: token, user: user)
    end
  end


  def check_auth(conn, _params) do
    user = conn.assigns[:current_user]
    render(conn, "authenticated.json", user: user)
  end
end
