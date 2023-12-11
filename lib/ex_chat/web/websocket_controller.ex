defmodule ExChat.Web.WebSocketController do
  @behaviour :cowboy_websocket
  require Logger

  alias ExChat.MessageStore
  alias ExChat.UseCases.{ValidateAccessToken, SendMessageToChatRoom,
    CreateChatRoom, JoinChatRoom, SubscribeToUserSession}

  def init(req, state) do
    access_token = access_token_from(req)

    case ValidateAccessToken.on(access_token) do
      {:ok, user_session} ->
        {:cowboy_websocket, req, user_session, %{idle_timeout: 1000 * 60 * 10}}
      {:error, :access_token_not_valid} ->
        {:ok, :cowboy_req.reply(400, req), state}
    end
  end

  def websocket_init(user_session) do
    SubscribeToUserSession.on(self(), user_session)

    {:ok, user_session}
  end

  def websocket_handle({:text, command_as_json}, session_id) do
    case from_json(command_as_json) do
      {:error, _reason} -> {:ok, session_id}
      {:ok, command} -> handle(command, session_id)
    end
  end

  def websocket_handle(_message, session_id) do
    {:ok, session_id}
  end

  def websocket_info(message, session_id) do
    {:reply, {:text, to_json(message)}, session_id}
  end

  defp handle(%{"command" => "join", "room" => room}, session_id) do

    # Envía los mensajes almacenados al usuario
    Logger.info("\n Join - #{session_id} user \n")

    # Al unirse a una sala, obtén los mensaes existentes
    messages = ExChat.MessageStore.get_messages(room)

    Logger.info("\n ------------- INITIAL --------------------")
    Logger.info("\n Message: #{inspect(messages)} \n")
    #Logger.info("\n rest: #{rest} \n")
    Logger.info("\n room: #{room} \n")
    Logger.info("\n session_id: #{session_id} \n")
    Logger.info("\n------------------------------------ \n")

    Logger.info("\n !!! Fin del envio de mensajes almacenados with #{session_id} user !!! \n")

    case JoinChatRoom.on(room, session_id) do
      :ok ->
        {:ok, session_id}
      {:error, message} ->
        {:reply, {:text, to_json(%{error: message})}, session_id}
    end

    #send_stored_messages(messages, room, session_id)

  end

  defp handle(command = %{"command" => "join"}, session_id) do
    Logger.info("\n Join 2 \n")
    handle(Map.put(command, "room", "default"), session_id)
  end

  defp handle(%{"room" => room, "message" => message}, session_id) do

    Logger.info("\n SendMessage \n")

    # Continúa con el resto del manejo del mensaje
    #IO.inspect(message, label: "Mensaje que llega al WebSocket")
    #IO.inspect(session_id, label: "Este es el usuario")

    case SendMessageToChatRoom.on(message, room, session_id) do
      {:error, message} ->
        {:reply, {:text, to_json(%{error: message})}, session_id}
      :ok ->
        # Almacenar el mensaje en el historial de la sala
        ExChat.MessageStore.add_message(room, session_id, message)
        # Imprimir el mensaje almacenado
        ExChat.MessageStore.print_messages(room)

        {:ok, session_id}
    end
  end

  defp handle(%{"command" => "create", "room" => room}, session_id) do

    Logger.info("\n Crear sala \n")

    response = case CreateChatRoom.on(room) do
      {:ok, message} -> %{success: message}
      {:error, message} -> %{error: message}
    end

    {:reply, {:text, to_json(response)}, session_id}
  end

  defp handle(_not_handled_command, session_id), do: {:ok, session_id}

  defp to_json(response), do: Poison.encode!(response)
  defp from_json(json), do: Poison.decode(json)

  defp access_token_from(req) do
    query_parameter =
      :cowboy_req.parse_qs(req)
      |> Enum.find(fn({key, _value}) -> key == "access_token" end)

    case query_parameter do
      {"access_token", access_token} -> access_token
      _ -> nil
    end
  end

  defp send_stored_messages([], _room, _session_id), do: :ok
  defp send_stored_messages([message | rest], room, session_id) do

    Logger.info("\n ------------- FINAL -------------------- \n")
    Logger.info("\n Message: #{inspect(message)} \n")
    Logger.info("\n Rest: #{inspect(rest)} \n")
    Logger.info("\n room: #{room} \n")
    Logger.info("\n session_id: #{session_id} \n")
    Logger.info("\n ------------------------------------ \n")

    # Envia un mensaje almacenado al usuario
    SendMessageToChatRoom.on(message, room, session_id)

    # Llama recursivamente para enviar el siguiente mensaje
    send_stored_messages(rest, room, session_id)
  end
end
