defmodule Server.Database do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, :ok}
  end

  def create(table) do
    GenServer.call(__MODULE__, {:create, table})
  end

  def delete(table) do
    GenServer.call(__MODULE__, {:delete, table})
  end

  def delete(table, key) do
    GenServer.call(__MODULE__, {:delete, table, key})
  end

  def read(table, key) do
    GenServer.call(__MODULE__, {:read, table, key})
  end

  def write(table, key, value) do
    GenServer.call(__MODULE__, {:write, table, {key, value}})
  end

  def search(table, criteria) do
    GenServer.call(__MODULE__, {:search, table, criteria})
  end

  defp search_criteria(_, :"$end_of_table", _, res) do
    res
  end

  defp search_criteria(table, current_key, {key, value}, res) do
    [{id, data}] = :ets.lookup(table, current_key)
    map = Map.merge(%{id: id}, data)
    case Map.has_key?(map, key) && Map.fetch!(map, key) == value do
      true -> search_criteria(table, :ets.next(table, current_key), {key, value}, res ++ map)
      false -> search_criteria(table, :ets.next(table, current_key), {key, value}, res)
    end
  end

  ### CALLBACK ###

  @impl true
  def handle_call({:create, table_name}, _from, intern_state) do
    case :ets.whereis(table_name) do
      :undefined ->
        :ets.new(table_name, [:named_table])
        {:reply, :ok, intern_state}
      _ -> {:reply, :error, intern_state}
      end
  end

  @impl true
  def handle_call({:read, table, key}, _from, intern_state) do
    case :ets.whereis(table) do
      :undefined -> {:reply, :error, intern_state}
      _ -> {:reply, :ets.lookup(table, key), intern_state}
    end
  end

  @impl true
  def handle_call({:write, table, {key, value}}, _from, intern_state) do
    case :ets.whereis(table) do
      :undefined -> {:reply, :error, intern_state}
      _ ->
        :ets.insert(table, {key, value})
        {:reply, :ok, intern_state}
    end
  end

  @impl true
  def handle_call({:delete, table, key}, _from, intern_state) do
    case :ets.whereis(table) do
      :undefined -> {:reply, :error, intern_state}
      _ ->
        :ets.delete(table, key)
        {:reply, :ok, intern_state}
    end
  end

  @impl true
  def handle_call({:delete, table}, _from, intern_state) do
    case :ets.whereis(table) do
      :undefined -> {:reply, :error, intern_state}
      _ ->
        :ets.delete(table)
        {:reply, :ok, intern_state}
    end
  end

  @impl true
  def handle_call({:search, table, criteria}, _from, intern_state) do
    case :ets.whereis(table) do
      :undefined -> {:reply, :error, intern_state}
      _ ->
        {:reply, {:ok, Enum.filter(
          Enum.map(criteria, fn {key, value} ->
            search_criteria(table, :ets.first(table), {key, value}, [])
          end), fn obj -> obj != [] end
        )}, intern_state}
    end
  end

  @impl true
  def handle_call(_, _from, intern_state) do
    {:reply, :error, intern_state}
  end

end
