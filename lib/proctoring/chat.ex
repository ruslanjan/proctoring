defmodule Proctoring.Chat do
  import Ecto.Query, warn: false
  alias Proctoring.Repo

  alias Proctoring.Accounts.User
  alias Proctoring.Chat.Message

  def clear_all_user_messages(%User{} = user) do
    query = from m in Message,
        where: m.to_user_id == ^user.id
    Repo.delete_all(query)
  end

  def clear_all_group_messages(group) when is_binary(group) do
    query = from m in Message,
        where: m.group == ^group
    Repo.delete_all(query)
  end

  def get_user_messages(%User{} = user) do
    query = from m in Message,
        where: m.to_user_id == ^user.id or (m.is_system == true and m.group == ^user.group),
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

  def get_all_system_messages(group) do
    query = from m in Message,
        where: m.is_system == true and m.group == ^group,
        order_by: m.inserted_at,
        preload: [:to_user]
    Repo.all(query)
  end

  def get_all_messages() do
    Repo.all(from m in Message, order_by: m.inserted_at)
  end

  def get_image(id) do
    message = Repo.get(Message, id)
    if not message.has_image do
      nil
    else
      message.image
    end
  end

  def send_system_message(message, group, {bytes, extension}) when is_binary(message) do
    message = %Message{}
    |>Message.changeset(%{is_system: true, group: group, message: message, to_user: nil, has_image: bytes != nil, image: bytes, image_extension: extension})
    |>Repo.insert!()
    |>Repo.preload(:to_user)
    ProctoringWeb.Endpoint.broadcast!("chat", "new_message", message)
    {:ok, message}
  end

  def send_message(from \\ "System", message, group, {bytes, extension} = _image, to_user) when is_binary(message) do
    message = %Message{}
    |>Message.changeset(%{is_system: false, group: group, from: from, message: message, to_user_id: to_user.id, has_image: bytes != nil, image: bytes, image_extension: extension})
    |>Repo.insert!()
    |>Repo.preload(:to_user)
    ProctoringWeb.Endpoint.broadcast!("chat", "new_message", message)
    {:ok, message}
  end

  def send_message_to_proctors(user, message, {bytes, extension} = _image) when is_binary(message) do
    message = %Message{}
    |>Message.changeset(%{is_system: false, group: user.group, from: user.name, message: message, to_user_id: user.id,  has_image: bytes != nil, image: bytes, image_extension: extension})
    |>Repo.insert!()
    |>Repo.preload(:to_user)
    ProctoringWeb.Endpoint.broadcast!("chat", "new_message", message)
    {:ok, message}
  end
end
