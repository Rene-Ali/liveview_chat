defmodule LiveviewChatWeb.MessageLive do
  use LiveviewChatWeb, :live_view
  alias LiveviewChat.Message
  alias LiveviewChat.PubSub

  def mount(_params, _session, socket) do
    if connected?(socket), do: Message.subscribe()

    messages = Message.list_messages() |> Enum.reverse()
    changeset = Message.changeset(%Message{}, %{})
    {:ok, assign(socket, messages: messages, changeset: changeset)}
  end

  def render(assigns) do
    LiveviewChatWeb.MessageView.render("messages.html", assigns)
  end

  def handle_event("new_message", %{"message" => params}, socket) do
    case Message.create_message(params) do
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      # broadcast returns :ok (just the atom!) if there are no errors
      :ok ->
        changeset = Message.changeset(%Message{}, %{"name" => params["name"]})
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete_message", %{"id" => id}, socket) do
    case Message.delete_message(id) do
      {:ok, _message} ->
        # Nachrichten nach dem Löschen aktualisieren
        messages = Message.list_messages() |> Enum.reverse()
        {:noreply, assign(socket, messages: messages)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not delete message")}
    end
  end

  def handle_info({:message_created, message}, socket) do
    messages = socket.assigns.messages ++ [message]
    {:noreply, assign(socket, messages: messages)}
  end
end
