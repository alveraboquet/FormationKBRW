defmodule TutoKbrwStack do
  use Application

  @impl true
  def start(_type, _args) do
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    Server.ServSupervisor.start_link(name: Server.ServSupervisor)
  end

  def create(table) do
    Server.Database.call({:create, table})
  end

  def delete(table) do
    Server.Database.call({:delete, table})
  end

  def delete(table, key) do
    Server.Database.call({:delete, table, key})
  end

  def read(table, key) do
    Server.Database.call({:read, table, key})
  end

  def write(table, key, value) do
    Server.Database.call({:write, table, {key, value}})
  end

end
