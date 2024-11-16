defmodule TestApp do
  use Application
  require HTTPServerSupervisor
  require HTTPResponse
  require Logger
  require JSON

  # every callback functions needs the request param
  # request contains all the request data
  # path,Method,Version,Body,Headers ...
  # When you are done just do HTTPResponse.create() with your data
  # There is no "MiddleWare" you implement your checks inside the function and just use em
  def start(_type,_args) do

    json_api = fn(request) ->
      Logger.info(request)
      test = %{hello: "world"}
      response_data = case JSON.encode(test) do
        {:ok, response_data} -> response_data
        {:error, _reason} -> nil
      end
      # HTTPResponse.create takes in HTTP version,Statuscode,your data and data type
      if response_data == nil do
        HTTPResponse.create("HTTP/1.1","400 Bad Request", "{\"info\":\"Error Encoding Json!!!\"}" ,"application/json")
      else
        HTTPResponse.create("HTTP/1.1","200 OK", response_data ,"application/json") #Return
      end
    end


    # Currently if you want cookies, then you need to cram all of that into the headers map
    test_json_api = fn(request) ->
      Logger.info(request)
      test = %{hello: "world"}

      response_body_str = case JSON.encode(test) do
        {:ok, response_data} -> response_data
        {:error, _reason} -> nil
      end

      headers = %{
        "Test" => "test",
        "Content-type" => "application/json",
      }

      response = %{
        "version" => "HTTP/1.1",
        "response_code" => "200 OK",
        "body" => response_body_str,
        "headers" => headers,
      }
      HTTPResponse.create(response) #Return
    end

    routes = %{
      "/api/test" => json_api, # register callback for route /api/test -> This function is used to generate responses for /api/test
      "/api/new_test" => test_json_api,
    }

    HTTPServerSupervisor.start_link(routes,"../public",8088)
  end

end
