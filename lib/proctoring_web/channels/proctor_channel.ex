defmodule ProctoringWeb.ProctorChannel do
  use Phoenix.Channel

  alias Proctoring.Accounts

  def join("proctor:", _payload, socket) do
    {:ok, socket}
  end

  def join("proctor:user:" <> user_id, _payload, socket) do
    user = socket.assigns[:current_user]

    if user_id != user.id do
      {:error, "wrong_room"}
    else
      {:ok, socket}
    end
  end

  def join("proctor:room:" <> room, _payload, socket) do
    user = socket.assigns[:current_user]
    IO.inspect(room)

    if Integer.to_string(user.room) != room and
         not Enum.member?(Accounts.list_group_rooms(user.group), user.room) and
         not user.is_admin do
      {:error, "wrong_room"}
    else
      {:ok, socket}
    end
  end

  def handle_in("proctor_joined", %{"body" => body}, socket) do
    user = socket.assigns[:current_user]

    if user.is_proctor do
      broadcast!(socket, "proctor_joined", %{"body" => body})
    end

    {:noreply, socket}
  end

  def handle_in("proctor_here", %{"body" => body}, socket) do
    broadcast_from!(socket, "proctor_here", %{"body" => body})
    {:noreply, socket}
  end

  def handle_in("user_here", %{"body" => body}, socket) do
    broadcast_from!(socket, "user_here", %{"body" => body})
    {:noreply, socket}
  end

  def handle_in("user_joined", %{"body" => body}, socket) do
    user = socket.assigns[:current_user]

    case not user.is_proctor do
      true ->
        broadcast!(socket, "user_joined", %{"body" => body})
        false
    end

    {:noreply, socket}
  end

  def handle_in("offerRTC", %{"body" => body}, socket) do
    broadcast_from!(socket, "offerRTC", %{"body" => body})
    {:noreply, socket}
  end

  def handle_in("answerRTC", %{"body" => body}, socket) do
    broadcast_from!(socket, "answerRTC", %{"body" => body})
    {:noreply, socket}
  end

  def handle_in("iceCandidate", %{"body" => body}, socket) do
    broadcast_from!(socket, "iceCandidate", %{"body" => body})
    {:noreply, socket}
  end

  def handle_in("user_left", %{"body" => body}, socket) do
    user = socket.assigns[:current_user]

    case not user.is_proctor do
      true ->
        broadcast!(socket, "user_left", %{"body" => body})
        false
    end
  end

  intercept ["offerRTC", "answerRTC", "iceCandidate"]

  def handle_out("iceCandidate", %{"body" => %{"receiver" => receiver}} = data, socket) do
    user = socket.assigns[:current_user]

    if user.id == receiver["id"] do
      push(socket, "iceCandidate", data)
    end

    {:noreply, socket}
  end

  def handle_out("answerRTC", %{"body" => %{"receiver" => receiver}} = data, socket) do
    user = socket.assigns[:current_user]

    if user.id == receiver["id"] do
      push(socket, "answerRTC", data)
    end

    {:noreply, socket}
  end

  def handle_out("offerRTC", %{"body" => %{"receiver" => receiver}} = data, socket) do
    user = socket.assigns[:current_user]

    if user.id == receiver["id"] do
      push(socket, "offerRTC", data)
    end

    {:noreply, socket}
  end

  # def handle_in("user_offer", %{"body" => body}, socket) do
  #   broadcast!(socket, "user_offer", %{body: body})
  #   {:noreply, socket}
  # end

  # def handle_out("proctor_joined", %{"body" => body}, socket) do
  #   broadcast_from! socket, "message", %{body: body}

  #   {:noreply, socket}
  # end

  def terminate(reason, socket) do
    user = socket.assigns[:current_user]
    IO.inspect("#{user.name} > leave #{inspect(reason)}")

    broadcast!(socket, "user_left", %{
      body: %{user: ProctoringWeb.UserView.render("user.json", %{user: user})}
    })

    :ok
  end
end
