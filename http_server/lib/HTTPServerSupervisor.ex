# Supervision tree
defmodule HTTPServerSupervisor do
  use Supervisor
  require HTTPServer
  def start_link(routes) do
    Supervisor.start_link(__MODULE__, routes ,name: __MODULE__)
  end
  def init(routes) do
     children = [
        %{
          id: HTTPServer,
          start: {HTTPServer, :start_link, [routes]},
          restart: :permanent,
          shutdown: 5000,
          type: :worker,
          modules: [HTTPServer]
        }
      ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
