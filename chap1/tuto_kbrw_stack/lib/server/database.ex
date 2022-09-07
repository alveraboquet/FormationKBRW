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
    :ets.new(table_name, [:named_table])
    {:reply, :ok, intern_state}
  end

  @impl true
  def handle_call({:read, table, key}, _from, intern_state) do
    {:reply, :ets.lookup(table, key), intern_state}
  end

  @impl true
  def handle_call({:write, table, {key, value}}, _from, intern_state) do
    :ets.insert(table, {key, value})
    {:reply, :ok, intern_state}
  end

  @impl true
  def handle_call({:delete, table, key}, _from, intern_state) do
    :ets.delete(table, key)
    {:reply, :ok, intern_state}
  end

  @impl true
  def handle_call({:delete, table}, _from, intern_state) do
    :ets.delete(table)
    {:reply, :ok, intern_state}
  end

end
