defmodule HTTPResponse do

# SO apparently in elixir arguments are reference based ?
  def add_headers(http_response,headers) do
    if headers == nil do
      http_response <> "\r\n"
    else
    http_response = http_response <> Enum.reduce(headers, "", fn {k, v}, http_response ->
      http_response <> k <> ": " <> v <> "\r\n"
    end)
    http_response <> "\r\n"
    end
  end

  # if body is nil or empty just returns http_response
  def add_body(http_response,body) do
    if body == nil do
      IO.puts("body is nil")
      http_response <> "\r\n"
    else
      http_response <> body <> "\r\n"
    end
  end


  # this might be removed in later versions, for now files are served with this
  def create(version,response_code,data,content_type) do
    raw_http_response = version <> " " <> response_code <> "\r\n"
    raw_http_response = raw_http_response <> "Content-type: #{content_type} \r\n"
    #raw_http_response = raw_http_response <> "Connection: close\r\n"
    raw_http_response = raw_http_response <> "\r\n"
    raw_http_response = raw_http_response <> data <> "\r\n"
    raw_http_response
  end

  #this takes a map instead
  #can be used for more complex responses
  def create(response_data_map) do
    raw_http_response = Map.get(response_data_map,"version") <> " " <> Map.get(response_data_map,"response_code") <> "\r\n"
    raw_http_response = add_headers(raw_http_response, Map.get(response_data_map,"headers"))
    raw_http_response = add_body(   raw_http_response,    Map.get(response_data_map,"body"))
   # IO.puts(raw_http_response)
    raw_http_response
  end




end
