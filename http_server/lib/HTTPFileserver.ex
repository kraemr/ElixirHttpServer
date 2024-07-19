defmodule HTTPFileServer do
  require HTTPResponse


  def detect_content_type(file_name) do

  end

  def serve_file_contents(root_dir, file_name) do
    {:ok, contents} = File.read(root_dir <> file_name)
    # if the file exists return 200 ok else 404 not found
    HTTPResponse.create("HTTP/1.1","200 OK",contents)
    contents
  end

end
