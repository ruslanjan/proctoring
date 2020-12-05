defmodule ProctoringWeb.AuthenticationPlug do
  @moduledoc false
  import Plug.Conn

  alias Proctoring.{Auth, Accounts}
  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- Auth.verify_auth_token(token),
         user <- Accounts.get_user(user_id),
         true <- user != nil do
      conn
      |> merge_assigns(current_user: user)
    else
      _ ->
        conn
        |> merge_assigns(current_user: nil)
    end
  end
end
