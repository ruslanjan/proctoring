defmodule ProctoringWeb.ChatController do
  use ProctoringWeb, :controller

  import Plug.Conn

  alias Proctoring.Accounts
  alias Proctoring.Chat
  alias Proctoring.Accounts.User
  import ProctoringWeb.Authorization

  action_fallback ProctoringWeb.FallbackController

  def get_bytes(hex) do
    if hex != nil do
      Base.decode64!(hex)
    else
      nil
    end
  end

  def get_image(conn, %{"file" => filename}) do
    [id, ext] = String.split(filename, ".")
    IO.inspect(id)
    IO.inspect(ext)
    bytes = Chat.get_image(id)
    conn
    |> put_resp_content_type(MIME.type(ext))
    |> put_resp_header("accept-ranges", "bytes")
    |> Plug.Conn.send_resp(:ok, bytes)
  end

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

  def send_message_to_user(conn, %{"message" => message, "image" => %{"bytes" => base64Bytes, "extension" => extension}, "to_user_id" => user_id}) do
    can?(conn, view?(Chat.Message))
    # user = conn.assigns[:current_user]
    to_user = Accounts.get_user!(user_id)

    {:ok, message} = Chat.send_message("Proctor", message, {get_bytes(base64Bytes), extension}, to_user)
    render(conn, "show.json", message: message)
  end

  def send_message_to_user(conn, %{"message" => _message, "to_user_id" => _user_id, "image" => nil} = data) do
    send_message_to_user(conn, Map.put(data, "image", %{"bytes" => nil, "extension" => nil}))
  end

  def send_system_message(conn, %{"message" => message, "image" => %{"bytes" => base64Bytes, "extension" => extension}}) do
    can?(conn, view?(Chat.Message))
    # user = conn.assigns[:current_user]
    {:ok, message} = Chat.send_system_message(message, {get_bytes(base64Bytes), extension})
    render(conn, "show.json", message: message)
  end

  def send_system_message(conn, %{"message" => _message, "image" => nil} = data) do
    send_system_message(conn, Map.put(data, "image", %{"bytes" => nil, "extension" => nil}))
  end

  def send_message_to_proctors(conn, %{"message" => message, "image" => %{"bytes" => base64Bytes, "extension" => extension}}) do
    user = conn.assigns[:current_user]
    {:ok, message} = Chat.send_message_to_proctors(user, message, {get_bytes(base64Bytes), extension})
    render(conn, "show.json", message: message)
  end

  def send_message_to_proctors(conn, %{"message" => _message, "image" => nil} = data) do
    send_message_to_proctors(conn, Map.put(data, "image", %{"bytes" => nil, "extension" => nil}))
  end
end
