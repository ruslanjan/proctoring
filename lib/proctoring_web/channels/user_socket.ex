defmodule ProctoringWeb.UserSocket do
  use Phoenix.Socket

  alias Proctoring.Auth
  alias Proctoring.Accounts

  ## Channels
  # channel "room:*", ProctoringWeb.RoomChannel
  channel "call", ProctoringWeb.CallChannel
  channel "proctor:*", ProctoringWeb.ProctorChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    with {:ok, user_id} <- Auth.verify_auth_token(token),
         user <- Accounts.get_user(user_id),
         true <- user != nil do
      {:ok, assign(socket, :current_user, user)}
    else
      _ ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ProctoringWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
