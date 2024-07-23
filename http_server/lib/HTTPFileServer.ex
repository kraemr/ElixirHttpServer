defmodule HTTPFileServer do
  require HTTPResponse
  require HTTPSanitizer
  @supported_filetypes %{
    "aac"   => "audio/aac",
    "abw"   => "application/x-abiword",
    "apng"  => "image/apng",
    "arc"   => "application/x-freearc",
    "avif"  => "image/avif",
    "avi"   => "video/x-msvideo",
    "azw"   => "application/vnd.amazon.ebook",
    "bin"   => "application/octet-stream",
    "bmp"   => "image/bmp",
    "bz"    => "application/x-bzip",
    "bz2"   => "application/x-bzip2",
    "cda"   => "application/x-cdf",
    "csh"   => "application/x-csh",
    "css"   => "text/css",
    "csv"   => "text/csv",
    "doc"   => "application/msword",
    "docx"  => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "eot"   => "application/vnd.ms-fontobject",
    "epub"  => "application/epub+zip",
    "gz"    => "application/gzip",
    "gif"   => "image/gif",
    "htm"   => "text/html",
    "html"  => "text/html",
    "ico"   => "image/vnd.microsoft.icon",
    "ics"   => "text/calendar",
    "jar"   => "application/java-archive",
    "jpeg"  => "image/jpeg",
    "jpg"   => "image/jpeg",
    "js"    => "text/javascript",
    "json"  => "application/json",
    "jsonld"=> "application/ld+json",
    "mid"   => "audio/midi",
    "midi"  => "audio/midi",
    "mjs"   => "text/javascript",
    "mp3"   => "audio/mpeg",
    "mp4"   => "video/mp4",
    "mpeg"  => "video/mpeg",
    "mpkg"  => "application/vnd.apple.installer+xml",
    "odp"   => "application/vnd.oasis.opendocument.presentation",
    "ods"   => "application/vnd.oasis.opendocument.spreadsheet",
    "odt"   => "application/vnd.oasis.opendocument.text",
    "oga"   => "audio/ogg",
    "ogv"   => "video/ogg",
    "ogx"   => "application/ogg",
    "opus"  => "audio/ogg",
    "otf"   => "font/otf",
    "png"   => "image/png",
    "pdf"   => "application/pdf",
    "php"   => "application/x-httpd-php",
    "ppt"   => "application/vnd.ms-powerpoint",
    "pptx"  => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "rar"   => "application/vnd.rar",
    "rtf"   => "application/rtf",
    "sh"    => "application/x-sh",
    "svg"   => "image/svg+xml",
    "tar"   => "application/x-tar",
    "tif"   => "image/tiff",
    "tiff"  => "image/tiff",
    "ts"    => "video/mp2t",
    "ttf"   => "font/ttf",
    "txt"   => "text/plain",
    "vsd"   => "application/vnd.visio",
    "wav"   => "audio/wav",
    "weba"  => "audio/webm",
    "webm"  => "video/webm",
    "webp"  => "image/webp",
    "woff"  => "font/woff",
    "woff2" => "font/woff2",
    "xhtml" => "application/xhtml+xml",
    "xls"   => "application/vnd.ms-excel",
    "xlsx"  => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "xml"   => "application/xml",
    "xul"   => "application/vnd.mozilla.xul+xml",
    "zip"   => "application/zip",
    "3gp"   => "video/3gpp",
    "3g2"   => "video/3gpp2",
    "7z"    => "application/x-7z-compressed"
  }

  def get_content_type(file_ending) do
    Map.get(@supported_filetypes,file_ending)
  end

  def detect_content_type(file_name) do
    arr = String.split(file_name,".")
    length = Enum.count(arr)
    if length > 0 do
      type = Enum.at(arr,length-1)
      get_content_type(type)
    else #no file extension
      "text/plain"
    end
  end

  def serve_file_contents(root_dir, file_name) do
    path = root_dir <> HTTPSanitizer.sanitize_path(file_name)
    IO.puts("reading file #{path}")
    response = case File.read(path) do
      {:ok, contents} ->
        type = detect_content_type(file_name)
        if type == nil do #invalid content type or doesnt exist
          HTTPResponse.create("HTTP/1.1","400 Bad Request","Bad Request","text/html")
        else
          HTTPResponse.create("HTTP/1.1","200 OK",contents,type)
        end
      {:error, :enoent} -> # File doesnt exist
        HTTPResponse.create("HTTP/1.1","404 Not Found","Not Found","text/html")
      {:error, :eisdir} -> # dont list directories
        HTTPResponse.create("HTTP/1.1","400 Bad Request","Bad Request","text/html")
    end
    response
  end

end
