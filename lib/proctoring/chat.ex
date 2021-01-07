defmodule Proctoring.Chat do
  import Ecto.Query, warn: false
  alias Proctoring.Repo

  alias Proctoring.Accounts.User
  alias Proctoring.Chat.Message

  def get_user_messages(%User{} = user) do
    query = from m in Message,
        where: m.to_user_id == ^user.id or m.is_system == true,
        order_by: m.inserted_at
    Repo.all(query)
    |>Repo.preload(:to_user)
  end

  def get_all_system_messages() do
    query = from m in Message,
        where: m.is_system == true,
        order_by: m.inserted_at,
        preload: [:to_user]
    Repo.all(query)
  end

  def get_all_messages() do
    Repo.all(from m in Message, order_by: m.inserted_at)
  end

  def send_system_message(message) when is_binary(message) do
    message = %Message{}
    |>Message.changeset(%{is_system: true, message: message, to_user: nil})
    |>Repo.insert!()
    |>Repo.preload(:to_user)
    ProctoringWeb.Endpoint.broadcast!("chat", "new_message", message)
    {:ok, message}
  end

  def send_message(from \\ "System", message, to_user) when is_binary(message) do
    message = %Message{}
    |>Message.changeset(%{is_system: false, from: from, message: message, to_user_id: to_user.id})
    |>Repo.insert!()
    |>Repo.preload(:to_user)
    ProctoringWeb.Endpoint.broadcast!("chat", "new_message", message)
    {:ok, message}
  end

  def send_message_to_proctors(user, message) when is_binary(message) do
    message = %Message{}
    |>Message.changeset(%{is_system: false, from: user.name, message: message, to_user_id: user.id})
    |>Repo.insert!()
    |>Repo.preload(:to_user)
    ProctoringWeb.Endpoint.broadcast!("chat", "new_message", message)
    {:ok, message}
  end
end
