defmodule HTTPRequestParser do
  @valid_methods ["GET","POST","PUT","DELETE"]
  @valid_versions ["HTTP/1.0","HTTP/1.1","HTTP/2","HTTP/3"]


    #todo add error handling
  def extract_method(request_data) do
    arr = String.split(request_data, " ")
    if Enum.member?(@valid_methods, Enum.at(arr, 0)) do
      {:ok, Enum.at(arr, 0) }
    else
      {:error, "Method not supported"}
    end
  end

  #todo add error handling
  def extract_path(request_data) do
    arr = String.split(request_data, " ")
    {:ok, Enum.at(arr, 1) }
  end


    #todo add error handling
  def extract_version(request_data) do
    arr = String.split(request_data, " ")
    if Enum.member?(@valid_versions, Enum.at(arr, 2)) do
      {:ok, Enum.at(arr, 2) }
    else
      {:error, "Invalid Data"}
    end
  end
end
