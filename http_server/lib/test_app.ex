defmodule TestApp do
  use Application
  require HttpServerApp
  def start(_type,_args) do
    routes = %{
      "/api/test" => fn -> HTTPResponse.create("HTTP/1.1", "200 OK", "Test Successful", "text/html") end,
    }
    HttpServerApp.start(routes)
  end
end
