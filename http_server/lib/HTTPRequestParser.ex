defmodule HTTPRequestParser do
  @valid_methods ["GET","POST","PUT","DELETE"]
  @valid_versions ["HTTP/1.0","HTTP/1.1","HTTP/2"]   # HTTP/2 will be implemented, HTTP/3 not for now


  def loop_header(header_list,header_map,n) when n > 0 do
    header = Enum.at(header_list,n)
    kv = String.split(header,":")
    key = Enum.at(kv,0)
    val = Enum.at(kv,1)
    val = String.replace(val," ","")
    map = Map.put(header_map,key,val)
    #IO.puts("key:#{key},value:#{val}")
    loop_header(header_list,map,n-1)
  end

  def loop_header(header_list,header_map,n) when n == 0 do
      header = Enum.at(header_list, n)
      kv = String.split(header,":")
      key = Enum.at(kv,0)
      val = Enum.at(kv,1)
      val = String.replace(val," ","")
      #IO.puts("key:#{key},value:#{val}")
      Map.put(header_map,key,val)
  end


  #TODO: add error handling
  def extract_headers(request_data) do
    arr = String.split(request_data,"\r\n\r\n")
    raw_headers = Enum.at(arr,0)
    header_list = String.split(raw_headers,"\r\n")
    map = loop_header(header_list,%{},length(header_list)-1)
    map
  end

  # Looks for \r\n followed directly by another \r\n
  # At the start of that is body till another \r\n
  def extract_body_data(request_data) do
    arr = String.split(request_data,"\r\n\r\n")
    if length(arr) >= 2 do
      Enum.at(arr,1)
    else
      nil
    end
  end

  def extract_method(request_data) do
    arr = String.split(request_data, " ")
    if Enum.member?(@valid_methods, Enum.at(arr, 0)) do
      {:ok, Enum.at(arr, 0) }
    else
      {:error, "Method not supported"}
    end
  end

  def extract_path_and_params(request_data) do
    arr = String.split(request_data, " ")
    path_and_params = Enum.at(arr, 1)
    splits = String.split(path_and_params, "?")
    if length(splits) > 2 do
      {:invalid_get,nil,nil}
    else
      {:ok, Enum.at(splits,0),Enum.at(splits,1)}
    end
  end

  #todo add error handling
  def extract_version(request_data) do
    arr = String.split(request_data, " ")
    if Enum.member?(@valid_versions, Enum.at(arr, 2)) do
      {:ok, Enum.at(arr, 2) }
    else
      {:error, "Invalid Version"}
    end
  end
end
