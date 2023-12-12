defmodule ExChat.UserSessions do
  use Supervisor

  alias ExChat.{UserSession, UserSessionRegistry}
  alias ExChat.GlobalListUS

  ##############
  # Client API #
  ##############

  def create(session_id) do
    case find(session_id) do
      nil ->
        add_to_global_list(session_id)
        start(session_id)
        :ok
      _pid ->
        {:error, :already_exists}
    end
  end

  def subscribe(client_pid, [to: session_id]) do
    case find(session_id) do
      nil -> {:error, :session_not_exists}
      pid -> UserSession.subscribe(pid, client_pid)
    end
  end

  def notify(message, [to: session_id]) do
    case find(session_id) do
      nil -> {:error, :session_not_exists}
      pid -> UserSession.notify(pid, message)
    end
  end

  def add_to_global_list(item) do
    GlobalListUS.add_element(item)
  end

  def get_global_list do
    GlobalListUS.get_list()
  end

  ####################
  # Server Callbacks #
  ####################

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [worker(UserSession, [])]
    supervise(children, strategy: :simple_one_for_one)
  end

  defp start(session_id) do
    name = {:via, Registry, {UserSessionRegistry, session_id}}

    Supervisor.start_child(__MODULE__, [name])
  end

  defp find(session_id) do
    listG = ExChat.GlobalListUS.get_list()
    #IO.inspect(listG, label: "Contenido de la lista global:")
    find_US(session_id,listG)
  end

  defp find_US(_session_id, []) do
    nil
  end

  defp find_US(session_id, [head | tail]) do
      if head == session_id do
        [{pid, nil}] = Registry.lookup(UserSessionRegistry, session_id)
        pid
      else
        find_US(session_id, tail)
      end
  end

end
