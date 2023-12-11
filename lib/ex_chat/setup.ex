defmodule ExChat.Setup do
  use Task, restart: :transient

  alias ExChat.{ChatRooms, UserSessions, AccessTokenRepository}

  def start_link(_args) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run() do
    # creacion de instancias por defecto
    ChatRooms.create("default")
  end
end
