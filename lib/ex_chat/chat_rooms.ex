

defmodule ExChat.ChatRooms do
  use Supervisor

  alias ExChat.{ChatRoom, ChatRoomRegistry}
  alias ExChat.GlobalList

  ##############
  # Client API #
  ##############

  def create(room) do
    case find(room) do
      {:ok, _pid} ->
        {:error, :already_exists}
      {:error, :unexisting_room} ->
        add_to_global_list(room)
        {:ok, _pid} = start(room)
        :ok
    end
  end

  def join(room, [as: session_id]) do
    case find(room) do
      {:ok, pid} ->
        try_join_chatroom(pid, session_id)
      {:error, :unexisting_room} ->
        {:error, :unexisting_room}
    end
  end

  def send(message, [to: room, as: session_id]) do
    case find(room) do
      {:ok, pid} -> ChatRoom.send(pid, message, as: session_id)
      error -> error
    end
  end

  defp try_join_chatroom(chatroom_pid, session_id) do
    case ChatRoom.join(chatroom_pid, session_id) do
      :ok ->
        :ok
      {:error, :already_joined} ->
        {:error, :already_joined}
    end
  end

  defp find(room) do
      listG = ExChat.GlobalList.get_list()
      IO.inspect(listG, label: "Contenido de la lista global:")
      find_room(room, listG)
  end

  defp find_room(_room, []) do
      {:error, :unexisting_room}
  end

  defp find_room(room, [head | tail]) do
      if head == room do
        [{pid, nil}] = Registry.lookup(ChatRoomRegistry, room)
        {:ok, pid}
      else
        find_room(room, tail)
      end
  end

  def add_to_global_list(item) do
    GlobalList.add_element(item)
  end

  def get_global_list do
    GlobalList.get_list()
  end


  ####################
  # Server Callbacks #
  ####################

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: :chatroom_supervisor)
  end

  def init(_) do
    children = [worker(ChatRoom, [])]
    supervise(children, strategy: :simple_one_for_one)
  end

  defp start(chatroom_name) do
    name = {:via, Registry, {ChatRoomRegistry, chatroom_name}}

    Supervisor.start_child(:chatroom_supervisor, [name])
  end
end
