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

  def valid_credentials?(%{"username" => username, "password" => password}) do
    # Aquí deberías tener lógica para verificar si las credenciales son válidas
    # Puedes acceder a la lista de usuarios almacenada en el estado del GenServer
    # y realizar la verificación adecuada
    user_list = get_list()
    Enum.any?(user_list, &match_credentials?(&1, username, password))
  end

  defp match_credentials?(user, username, password) do
    # Aquí defines la lógica para comparar el usuario y la contraseña
    # con las credenciales proporcionadas
    # Este es solo un ejemplo, deberías adaptarlo según tu implementación
    Map.get(user, "username") == username && Map.get(user, "password") == password
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
