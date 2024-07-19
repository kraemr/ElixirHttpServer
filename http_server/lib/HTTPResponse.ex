# This module is mainly for formatting HTTPResponses
defmodule HTTPResponse do
  def create(version,response_code,data) do
    raw_http_response = version <> " " <> response_code <> "\r\n"
    raw_http_response = raw_http_response <> "Host: 127.0.0.1:8081\r\n"
    raw_http_response = raw_http_response <> "Connection: Closed\r\n"
    raw_http_response = raw_http_response <>"Content-Type: text/html; charset=iso-8859-1\r\n"
    raw_http_response = raw_http_response <> "\r\n"
    raw_http_response = raw_http_response <> data <> "\r\n"
    raw_http_response
  end
end
