# Supervision tree
defmodule HttpServerSupervisor do
  use Supervisor
  require HttpServer
  def start_link(routes) do
    Supervisor.start_link(__MODULE__, routes ,name: __MODULE__)
  end
  def init(routes) do
     children = [
        %{
          id: HttpServer,
          start: {HttpServer, :start_link, [routes]},
          restart: :permanent,
          shutdown: 5000,
          type: :worker,
          modules: [HttpServer]
        }
      ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
