defmodule ProctoringWeb.UserController do
  use ProctoringWeb, :controller

  import Plug.Conn

  alias Proctoring.Accounts
  alias Proctoring.Accounts.User
  import ProctoringWeb.Authorization

  action_fallback ProctoringWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def list_users_in_room(conn, %{ "room" => room }) do
    case Integer.parse(room) do
      {room, ""} ->
        users = Accounts.list_users_in_room(room)
        render(conn, "index.json", users: users)
      _ ->
        conn
        |> send_resp(400, "")
    end
  end

  def create(conn, %{"user" => user_params}) do
    with can?(conn, create?(User)),
         {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    can?(conn, view?(User))
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    can?(conn, update?(User))
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    can?(conn, delete?(User))
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
