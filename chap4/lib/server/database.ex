defmodule Server.Database do
  use GenServer

  def start_link(_) do
    :ets.new(:database, [:named_table, :public])
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, :ok}
  end

  def create(table, key, value) do
    GenServer.call(__MODULE__, {:create, table, {key, value}})
  end

  def delete(table, key) do
    GenServer.call(__MODULE__, {:delete, table, key})
  end

  def read(table, key) do
    GenServer.call(__MODULE__, {:read, table, key})
  end

  def update(table, key, value) do
    GenServer.call(__MODULE__, {:update, table, {key, value}})
  end

  def search(table, criteria) do
    GenServer.call(__MODULE__, {:search, table, criteria})
  end

  defp search_criteria(_, :"$end_of_table", _, res) do
    res
  end

  defp search_criteria(table, current_key, {key, value}, res) do
    [{_id, data}] = :ets.lookup(table, current_key)
    case is_map(data) && Map.has_key?(data, key) && Map.fetch!(data, key) == value do
      true -> search_criteria(table, :ets.next(table, current_key), {key, value}, res ++ [data])
      false -> search_criteria(table, :ets.next(table, current_key), {key, value}, res)
    end
  end

  ### CALLBACK ###

  @impl true
  def handle_call({:create, table, {key, value}}, _from, intern_state) do
    case :ets.whereis(table) do
      :undefined -> {:reply, :error, intern_state}
      _ -> case :ets.insert_new(table, {key, value}) do
        true -> {:reply, :ok, intern_state}
        false -> {:reply, :error, intern_state}
      end
    end
  end

  @impl true
  def handle_call({:update, table, {key, value}}, _from, intern_state) do
    case :ets.whereis(table) do
      :undefined -> {:reply, :error, intern_state}
      _ -> case :ets.lookup(table, key) do
        [] -> {:reply, :error, intern_state}
        _ -> :ets.insert(table, {key, value})
          {:reply, :ok, intern_state}
      end
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
  def handle_call({:delete, table, key}, _from, intern_state) do
    case :ets.whereis(table) do
      :undefined -> {:reply, :error, intern_state}
      _ ->
        :ets.delete(table, key)
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
#            search_criteria({key, value}, :ets.tab2list(table))
          end), fn obj -> obj != [] end
        )}, intern_state}
    end
  end

  @impl true
  def handle_call(_, _from, intern_state) do
    {:reply, :error, intern_state}
  end

end
