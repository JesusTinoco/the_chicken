defmodule HenhouseServer do
  use GenServer

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: Henhouse)
  end

  def read do
    GenServer.call(Henhouse, {:read})
  end

  def get(username) do
    GenServer.call(Henhouse, {:get, username})
  end

  def take(username) do
    GenServer.call(Henhouse, {:take, username})
  end

  def add(username) do
    GenServer.call(Henhouse, {:add, username})
  end

  def clean do
    GenServer.call(Henhouse, {:clean})
  end

  # Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:read}, _from, map) do {:reply, map, map} end
  def handle_call({:get, username}, _from, map) do {:reply, Map.get(map, username), map} end
  def handle_call({:take, username}, _from, map) do {:reply, Map.take(map, [username]), map} end
  def handle_call({:add, username}, _from, map) do
    map_updated = Map.update(map, username, 1, &(&1 + 1))
    {:reply, Map.take(map_updated, [username]), map_updated}
  end
  def handle_call({:clean}, _from, _map) do {:reply, %{}, %{}} end
end
