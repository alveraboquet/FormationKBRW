defmodule Server.Database do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, :ok}
  end

  def call(request) do
    GenServer.call(__MODULE__, request)
  end

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
  def handle_call(_, _from, intern_state) do
    {:reply, :error, intern_state}
  end

end
