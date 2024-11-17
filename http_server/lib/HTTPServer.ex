defmodule HTTPServer do
   require Logger
   require HTTPResponse
   require HTTPRequestParser
   require HTTPFileServer

   def start(%{routes: routes,root_dir: root_dir,port: port} = init_obj) do
     {:ok, listen_socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true, keepalive: true])
     accept_loop(listen_socket,init_obj)
   end

   defp accept_loop(listen_socket,init_obj) do
     {:ok, client_socket} = :gen_tcp.accept(listen_socket)
     spawn(fn -> handle_client(client_socket,init_obj) end)
     accept_loop(listen_socket,init_obj)
   end


   #Respond to received Http Data
   defp handle_http_request(socket,data,%{routes: routes,root_dir: root_dir} = state) do
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
        :inet.setopts(socket, active: :once)
        {:noreply, state}
     else # else we try sending the file
        response = HTTPFileServer.serve_file_contents(root_dir,path)
        :ok = :gen_tcp.send(socket, response)
        :inet.setopts(socket, active: :once)
        {:noreply, state}
     end
  end

   defp handle_client(socket, %{routes: routes,root_dir: root_dir} = state) do
     case :gen_tcp.recv(socket, 0) do
       {:ok, data} ->
         handle_http_request(socket,data,state)
         handle_client(socket,state) # Continue handling client requests

       {:error, :closed} ->
         IO.puts("Client closed the connection")
         :gen_tcp.close(socket)
       {:error, :einval} ->
         :gen_tcp.close(socket)


     end
   end
 end
