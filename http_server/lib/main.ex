
# Supervision tree
defmodule HttpServerSupervisor do
   use Supervisor

   def start_link(_) do
     Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
   end

   def init(:ok) do
     children = [
       {HttpServer, []}
     ]

     Supervisor.init(children, strategy: :one_for_one)
   end
 end


defmodule HttpServer do
   require Logger
   use GenServer
   @port 8081
#    {:ok, socket} = :gen_tcp.listen(@port, [:binary, packet: :raw, active: false, reuseaddr: true])
   def start_link(_) do
      GenServer.start_link(__MODULE__, %{socket: nil}, name: __MODULE__)
    end

   def init(state) do
      {:ok, socket} = :gen_tcp.listen(@port, [:binary, active: false, packet: :raw, reuseaddr: true])
      send(self(), :accept)

      Logger.info "Accepting connection on port #{@port}..."
      {:ok, %{state | socket: socket}}
   end

   def handle_info(:accept, %{socket: socket} = state) do
      {:ok, client} = :gen_tcp.accept(socket)
      Logger.info("Client connected")
      :gen_tcp.controlling_process(client, self())
      :inet.setopts(client, active: :once)  # Set the socket to active mode for one messagE
      send(self(), :accept)
      {:noreply, state}
   end

   def handle_info({:tcp, socket, data}, state) do
      Logger.info "Received \n#{data}"
      Logger.info "Sending it back"
      :ok = :gen_tcp.send(socket, data)
      {:noreply, state}
   end

   def handle_info({:tcp_closed, socket}, state) do
      Logger.info("Client disconnected")
      {:noreply, state}
   end

   def handle_info({:tcp_error, socket, reason}, state) do
      Logger.error("TCP error: #{reason}")
      {:noreply, state}
   end
end


# Start the application
defmodule HttpServerApp do
   use Application

   def start(_type, _args) do
     HttpServerSupervisor.start_link([])
   end
 end
