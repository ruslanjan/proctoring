defmodule ProctoringWeb.UserView do
  use ProctoringWeb, :view
  alias ProctoringWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username,
      name: user.name,
      room: user.room,
      is_proctor: user.is_proctor,
      is_admin: user.is_admin
    }
  end
end
