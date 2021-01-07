defmodule ProctoringWeb.ChatChannel do
  use Phoenix.Channel

  def join("chat", _payload, socket) do
    {:ok, socket}
  end

  intercept ["new_message"]

  def handle_out("new_message", %{:to_user => to_user, :is_system => is_system} = data, socket) do
    user = socket.assigns[:current_user]

    if is_system or (to_user != nil and user.id == to_user.id) or user.is_admin or user.is_proctor do
      push(socket, "new_message", data)
    end

    {:noreply, socket}
  end

  # def join("proctor:" <> room, _payload, socket) do
  #   user = socket.assigns[:current_user]
  #   IO.inspect(room)
  #   if Integer.to_string(user.room) != room and not user.is_admin and false do
  #     {:error, "wrong_room"}
  #   else
  #     {:ok, socket}
  #   end
  # end

end
