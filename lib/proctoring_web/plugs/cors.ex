defmodule ProctoringWeb.Plugs.Cors do
  @moduledoc """
  sets up cors header
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, _opts) do
    conn =
      conn
      |> put_resp_header("access-control-allow-origin", "*")
      |> put_resp_header("access-control-allow-methods", "POST, GET, OPTIONS, PUT, DELETE")
      |> put_resp_header(
        "access-control-allow-headers",
        "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, RecaptchaV3-Token"
      )

    case conn.method do
      "OPTIONS" ->
        conn
        |> send_resp(204, "")
        |> halt()

      _ ->
        conn
    end
  end
end
