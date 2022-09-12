defmodule Server.PlugSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, {}, opts)
  end

  def init(_) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Server.Router, options: [port: 4001]},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
