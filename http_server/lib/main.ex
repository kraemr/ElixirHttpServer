

# Supervision tree
defmodule HttpServerSupervisor do
   use Supervisor
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

defmodule HttpServer do
   require Logger
   require HTTPResponse
   require HTTPRequestParser
   require HTTPFileServer
   use GenServer
   @port 8081 #TODO: Make this something to pass in init or on app_start, and add option to specify listen_ip
   @root_dir "../public" #TODO: Make this something to pass in init or on app_start or in env


   def start_link(routes) do
      GenServer.start_link(__MODULE__, %{socket: nil,routes: routes}, name: __MODULE__)
   end

   def init(state) do
      {:ok, socket} = :gen_tcp.listen(@port, [:binary, active: false, packet: :raw, reuseaddr: true])
      send(self(), :accept)
      Logger.info "Accepting connections on port #{@port}..."
      {:ok, %{state | socket: socket}}
   end

   def handle_info(:accept, %{socket: socket} = state) do
      {:ok, client} = :gen_tcp.accept(socket)
      :gen_tcp.controlling_process(client, self())
      :inet.setopts(client, active: :once)  # Set the socket to active mode for one messagE
      send(self(), :accept)
      {:noreply, state}
   end

   #Respond to received Http Data
   def handle_info({:tcp, socket, data}, %{routes: routes} = state) do
      # trim out all the other lines to not pass around the entire buffer everytime
      # as we only want to know what kind of request this is
      first_line = data |> String.split("\r\n") |> List.first()
      body = HTTPRequestParser.extract_body_data(data)
      method = case HTTPRequestParser.extract_method(first_line) do
         {:ok, method} -> method
         {:error, reason} -> nil
      end

      version = case HTTPRequestParser.extract_version(first_line) do
         {:ok, version} -> version
         {:error, reason} -> nil
      end

      path = case HTTPRequestParser.extract_path(first_line) do
         {:ok, path} -> path
         {:error, reason} -> nil
      end

      if path && Map.has_key?(routes, path) do
         function = Map.get(routes, path)

         response = function.(%{path: path, method: method, version: version, body: body})

         :ok = :gen_tcp.send(socket, response)
         :gen_tcp.close(socket)
         {:noreply, state}
      else
         response = HTTPFileServer.serve_file_contents(@root_dir,path)
         :ok = :gen_tcp.send(socket, response)
         :gen_tcp.close(socket)  # Properly close the socket
         {:noreply, state}
      end
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


# User facing API to use
# Just supply API Routes with your callback functions and it just works!
defmodule HttpServerApp do
   def start(routes) do
      HttpServerSupervisor.start_link(routes)
   end
 end
