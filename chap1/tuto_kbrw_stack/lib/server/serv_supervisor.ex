defmodule Server.ServSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, {}, opts)
  end

  def init(_) do
    children = [
      {Server.Database, name: Database},
      {Server.JsonLoader, name: JsonLoader}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
