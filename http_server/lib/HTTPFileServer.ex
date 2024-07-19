defmodule HTTPFileServer do
  require HTTPResponse
  @supported_filetypes %{
    "webp" =>   "image/webp",
    "png"  =>   "image/png",
    "jpeg" =>   "image/jpeg",
    "jpg"  =>   "image/jpeg",
    "ico"  =>   "image/x-icon",
    "css"  =>   "text/css",
    "txt"  =>   "text/text",
    "html" =>   "text/html",
    "js"   =>   "application/javascript",
    "json" =>   "application/json; charset=UTF-8",
    "xml" =>   "application/xml; charset=UTF-8",
    "woff2"=>   "application/octet-stream",
    "woff" =>   "application/octet-stream"
  }


  def get_content_type(file_ending) do
    Map.get(@supported_filetypes,file_ending)
  end

  def detect_content_type(file_name) do
    arr = String.split(file_name,".")
    length = Enum.count(arr)
    # if length = 0 error
    if length > 0 do
      type = Enum.at(arr,length-1)
      Map.get(@supported_filetypes,type)
    else
      "text/text"
    end

  end

  def serve_file_contents(root_dir, file_name) do
    path = root_dir <> file_name
    response = case File.read(path) do
      {:ok, contents} ->
        HTTPResponse.create("HTTP/1.1","200 OK",contents,detect_content_type(file_name))
      {:error, :enoent} ->
        HTTPResponse.create("HTTP/1.1","404 Not Found","Not Found","text/html")
      {:error, :eisdir} ->
        HTTPResponse.create("HTTP/1.1","400 Bad Request","Bad Request","text/html")
    end
    response
  end

end
