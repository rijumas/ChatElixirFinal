defmodule ExChat.GlobalListUC do
  use GenServer

  def start_link(initial_state \\ []) do
    GenServer.start_link(__MODULE__, initial_state, name: ExChat.GlobalListUC)
  end

  def add_element(element) do
    GenServer.cast(ExChat.GlobalListUC, {:add_element, element})
  end

  def get_list do
    GenServer.call(ExChat.GlobalListUC, :get_list)
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def handle_cast({:add_element, element}, state) do
    updated_state = [element | state]
    {:noreply, updated_state}
  end

  def handle_call(:get_list, _from, state) do
    {:reply, state, state}
  end
end
