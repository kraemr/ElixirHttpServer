defmodule TestApp do
  use Application
  require HttpServerApp
  require HTTPResponse
  require Logger
  require JSON




  # every callback functions needs request param
  # request contains all the request data
  # path,Method,Version,Body,Header ...
  # When you are done just do HTTPResponse.create() with your data
  def start(_type,_args) do

    json_api = fn(request) ->
      Logger.info(request)
      test = %{hello: "world"}
      response_data = case JSON.encode(test) do
        {:ok, response_data} -> response_data
        {:error, _reason} -> nil
      end
      if response_data == nil do
        HTTPResponse.create("HTTP/1.1","200 OK", "{\"info\":\"Error Encoding Json!!!\"}" ,"application/json")
      else
        HTTPResponse.create("HTTP/1.1","200 OK", response_data ,"application/json")
      end
    end

    routes = %{
      "/api/test" => json_api,
    }
    HttpServerApp.start(routes)
  end

end
