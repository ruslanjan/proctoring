defmodule ProctoringWeb.ChatView do
  use ProctoringWeb, :view
  alias ProctoringWeb.ChatView
  alias ProctoringWeb.UserView

  def render("list.json", %{messages: messages}) do
    %{data: render_many(messages, ChatView, "message.json")}
  end

  def render("show.json", %{message: message}) do
    %{data: render_one(message, ChatView, "message.json")}
  end

  def render("message.json", %{chat: message}) do
    %{id: message.id,
      is_system: message.is_system,
      from: message.from,
      to_user: render_one(message.to_user, UserView, "user.json"),
      message: message.message,
      has_image: message.has_image,
      image_extension: message.image_extension,
      inserted_at: message.inserted_at,
    }
  end

  def render("image.json", %{image: image}) do
    %{image: image}
  end
end
