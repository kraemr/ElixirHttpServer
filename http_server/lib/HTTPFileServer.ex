defmodule HTTPFileServer do
  require HTTPResponse
  def detect_content_type(file_name) do

  end

  def serve_file_contents(root_dir, file_name) do
    path = root_dir <> file_name
    IO.puts(path)
    response = case File.read(path) do
      {:ok, contents} -> HTTPResponse.create("HTTP/1.1","200 OK",contents)
      {:error, :enoent} -> HTTPResponse.create("HTTP/1.1","404 Not Found","Not Found")
      {:error, :eisdir} -> HTTPResponse.create("HTTP/1.1","400 Bad Request","Bad Request")
    end
    response
  end

end
