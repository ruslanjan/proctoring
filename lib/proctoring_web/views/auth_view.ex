defmodule ProctoringWeb.AuthView do
  use ProctoringWeb, :view

  def render("login.json", %{token: token, user: user}) do
    %{token: token, user: render_one(user, ProctoringWeb.UserView, "user.json")}
  end

  def render("authenticated.json", %{user: user}) do
    %{user: render_one(user, ProctoringWeb.UserView, "user.json")}
  end
end
