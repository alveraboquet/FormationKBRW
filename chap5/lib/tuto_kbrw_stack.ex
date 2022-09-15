defmodule TutoKbrwStack do
  use Application

  @impl true
  def start(_type, _args) do
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    Server.ServSupervisor.start_link(name: Server.ServSupervisor)
    Server.PlugSupervisor.start_link([strategy: :one_for_one, name: Server.PlugSupervisor])
  end

end
