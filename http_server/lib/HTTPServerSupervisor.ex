# Supervision tree
defmodule HTTPServerSupervisor do
  use Supervisor
  require HTTPServer

  def start_link(routes,root_dir,port) do
    Supervisor.start_link(__MODULE__, %{routes: routes,root_dir: root_dir,port: port} ,name: __MODULE__)
  end

  def init(init_obj) do
     children = [
        %{
          id: HTTPServer,
          start: {HTTPServer, :start, [init_obj]},
          restart: :permanent,
          shutdown: 5000,
          type: :worker,
          modules: [HTTPServer]
        }
      ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
