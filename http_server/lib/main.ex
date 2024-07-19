

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
   require HTTPResponse
   require HTTPRequestParser
   require HTTPFileServer

   use GenServer
   @port 8081 #TODO: Make this something to pass in init or on app_start, and add option to specify listen_ip
   @root_dir "../public" #TODO: Make this something to pass in init or on app_start or in env

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
      #Logger.info("Client connected")
      :gen_tcp.controlling_process(client, self())
      :inet.setopts(client, active: :once)  # Set the socket to active mode for one messagE
      send(self(), :accept)
      {:noreply, state}
   end

   #Respond to received Http Data
   def handle_info({:tcp, socket, data}, state) do
      # trim out all the other lines to not pass around the entire buffer everytime
      # as we only want to know what kind of request this is
      first_line = data |> String.split("\r\n") |> List.first()
      result = case HTTPRequestParser.extract_method(first_line) do
         {:ok, method} -> {:ok, method}
         {:error, reason} -> {:error, reason}
      end

      method = case result do
         {:ok, method} -> method
         {:error, _reason} -> nil
      end

      result = case HTTPRequestParser.extract_version(first_line) do
         {:ok, version} -> {:ok, version}
         {:error, reason} -> {:error, reason}
      end

      version = case result do
         {:ok, version} -> version
         {:error, _reason} -> nil
      end

      result = case HTTPRequestParser.extract_path(first_line) do
         {:ok, path} -> {:ok, path}
         {:error, reason} -> {:error, reason}
      end

      path = case result do
         {:ok, path} -> path
         {:error, _reason} -> nil
      end

      if path != nil do
         #path = String.replace_leading(path, "/", "")
         #IO.puts("serving file: #{path}")
         response = HTTPFileServer.serve_file_contents(@root_dir,path)
         :ok = :gen_tcp.send(socket, response)
         :gen_tcp.close(socket)  # Properly close the socket
         {:noreply, state}
      else
         response = HTTPResponse.create("HTTP/1.1","404 Not Found","Not Found")
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


# Start the application
defmodule HttpServerApp do
   use Application

   def start(_type, _args) do
     HttpServerSupervisor.start_link([])
   end
 end
