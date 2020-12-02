defmodule ProctoringWeb.PageController do
  use ProctoringWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
