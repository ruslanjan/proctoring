defmodule ProctoringWeb.ChatController do
  use ProctoringWeb, :controller

  import Plug.Conn

  alias Proctoring.Accounts
  alias Proctoring.Chat
  alias Proctoring.Accounts.User
  import ProctoringWeb.Authorization

  action_fallback ProctoringWeb.FallbackController

  def get_my_messages(conn, _params) do
    user = conn.assigns[:current_user]
    messages = Chat.get_user_messages(user)
    render(conn, "list.json", messages: messages)
  end

  def get_user_messages(conn, %{"to_user_id" => to_user_id}) do
    can?(conn, view?(Chat.Message))
    user = Accounts.get_user!(to_user_id)
    messages = Chat.get_user_messages(user)
    render(conn, "list.json", messages: messages)
  end

  def get_system_messages(conn, _params) do
    can?(conn, view?(Chat.Message))
    messages = Chat.get_all_system_messages()
    render(conn, "list.json", messages: messages)
  end

  def send_message_to_user(conn, %{"message" => message, "to_user_id" => user_id}) do
    can?(conn, view?(Chat.Message))
    # user = conn.assigns[:current_user]
    to_user = Accounts.get_user!(user_id)
    {:ok, message} = Chat.send_message("Proctor", message, to_user)
    render(conn, "show.json", message: message)
  end

  def send_system_message(conn, %{"message" => message}) do
    can?(conn, view?(Chat.Message))
    # user = conn.assigns[:current_user]
    {:ok, message} = Chat.send_system_message(message)
    render(conn, "show.json", message: message)
  end

  def send_message_to_proctors(conn, %{"message" => message}) do
    user = conn.assigns[:current_user]
    {:ok, message} = Chat.send_message_to_proctors(user, message)
    render(conn, "show.json", message: message)
  end
end
