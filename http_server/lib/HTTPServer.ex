defmodule HTTPServer do
   require Logger
   require HTTPResponse
   require HTTPRequestParser
   require HTTPFileServer
   use GenServer

   #@port 8081 #TODO: Make this something to pass in init or on app_start, and add option to specify listen_ip
   #@root_dir "../public" #TODO: Make this something to pass in init or on app_start or in env

   def start_link(init_obj) do
      init_obj = Map.put(init_obj,:socket,nil)
      GenServer.start_link(__MODULE__, init_obj, name: __MODULE__)
   end

   def init(%{port: port} = state) do
      {:ok, socket} = :gen_tcp.listen(port, [:binary, active: false, packet: :raw, reuseaddr: true])
      send(self(), :accept)
      Logger.info "Accepting connections on port #{port}..."
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
   def handle_info({:tcp, socket, data}, %{routes: routes,root_dir: root_dir} = state) do

      # trim out all the other lines to not pass around the entire buffer everytime
      # as we only want to know what kind of request this is
      first_line = data |> String.split("\r\n") |> List.first()
      body = HTTPRequestParser.extract_body_data(data)

      # extract_headers takes in data WITHOUT the first line, this is achieved by replacing the first line
      headers = HTTPRequestParser.extract_headers(String.replace(data,first_line <> "\r\n",""))

      method = case HTTPRequestParser.extract_method(first_line) do
         {:ok, method} -> method
         {:error, reason} -> nil
      end

      version = case HTTPRequestParser.extract_version(first_line) do
         {:ok, version} -> version
         {:error, reason} -> nil
      end

      {path , params} = case HTTPRequestParser.extract_path_and_params(first_line) do
         {:ok, path, params} -> {path, params}
         {:invalid_get,nil,nil} -> {nil,nil}
      end

      # if path is not nil and the route exists, then execute the callback function specified
      if path && Map.has_key?(routes, path) do
         function = Map.get(routes, path)
         response = function.(%{path: path, params: params, method: method, version: version, body: body,headers: headers})
         :ok = :gen_tcp.send(socket, response)
         :gen_tcp.close(socket)
         {:noreply, state}
      else # else we try sending the file
         response = HTTPFileServer.serve_file_contents(root_dir,path)
         :ok = :gen_tcp.send(socket, response)
         :gen_tcp.close(socket)
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
