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
    loop_header(header_list,map,n-1)
  end

  def loop_header(header_list,header_map,n) when n == 0 do
      header = Enum.at(header_list, n)
      kv = String.split(header,":")
      key = Enum.at(kv,0)
      val = Enum.at(kv,1)
      val = String.replace(val," ","")
      Map.put(header_map,key,val)
  end


  def extract_headers(request_data) do
    if request_data == nil do
      nil
    else
      arr = String.split(request_data,"\r\n\r\n")
	    raw_headers = Enum.at(arr,0)
      header_list = String.split(raw_headers,"\r\n")
	    if length(header_list) == 0 do
	      nil
	    else
	      map = loop_header(header_list,%{},length(header_list)-1)
	      map
	    end
    end
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


  # Tcp Connection but did not send http compliant request
  # For example a Portscan would trigger this
  def extract_path_and_params(request_data) when length(request_data) == 0 do
    {:invalid_get,nil,nil}
  end

  def extract_path_and_params(request_data) when request_data == nil do
    {:invalid_get,nil,nil}
  end

  def extract_path_and_params(request_data) do
    arr = String.split(request_data, " ")
    cond do
      length(arr) != 3 -> {:invalid_get,nil,nil}
      length(arr) == 3 ->
        splits = String.split(Enum.at(arr, 1), "?");
        if length(splits) == 1 do #return nil as params
          {:ok, Enum.at(splits,0),nil}
        else
          {:ok, Enum.at(splits,0),Enum.at(splits,1)}
        end
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
