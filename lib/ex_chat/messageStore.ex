defmodule ExChat.MessageStore do
  use GenServer

  def start_link(initial_state \\ []) do
    GenServer.start_link(__MODULE__, initial_state, name: ExChat.MessageStore)
  end

  # API pública
  def add_message(room, user, message) do
    GenServer.cast(__MODULE__, {:add_message, room, user, message})
  end

  def get_messages(room) do
    GenServer.call(__MODULE__, {:get_messages, room})
  end

  def print_messages(room) do
    messages = get_messages(room)
    IO.puts("Messages for room #{room}:")
    Enum.each(messages, &IO.puts("#{elem(&1, 0)}: #{elem(&1, 1)}"))
  end

  # Implementación del GenServer
  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:add_message, room, user, message}, state) do
    messages = Map.get(state, room, [])
    new_messages = [{user, message} | messages]
    new_state = Map.put(state, room, new_messages)
    {:noreply, new_state}
  end

  def handle_call({:get_messages, room}, _from, state) do
    messages = Map.get(state, room, [])
    {:reply, messages, state}
  end
end
