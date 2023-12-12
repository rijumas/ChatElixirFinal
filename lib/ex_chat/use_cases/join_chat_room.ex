defmodule ExChat.UseCases.JoinChatRoom do

  alias ExChat.{ChatRooms, UserSessions}

  def on(room, user_id) do
    case ChatRooms.join(room, as: user_id) do
      :ok ->
        #UserSessions.notify(%{room: room, message: "welcome to the #{room} chat room, #{user_id}!"}, to: user_id)
        UserSessions.notify(%{room: room, cod: "100"}, to: user_id)
        :ok
      {:error, :already_joined} ->
        #{:error, "you already joined the #{room} room!"}
        {:cod, "200"}
      {:error, :unexisting_room} ->
        {:error, "#{room} does not exists"}
    end
  end
end
