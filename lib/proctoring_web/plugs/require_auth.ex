defmodule ProctoringWeb.RequireAuthenticationPlug do
  @moduledoc false
  import Plug.Conn
  import Phoenix.Controller
  alias Proctoring.Accounts.User

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, _opts) do
    case conn.assigns[:current_user] do
      %User{} ->
        conn
      nil ->
        conn
        |> put_status(401)
        |> json(%{
          error: "Вы не авторизованны"
        })
        |> halt()
    end
  end
end
