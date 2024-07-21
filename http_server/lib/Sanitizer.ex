# Sanitizes things like Get Params, localhost/../../ ...
defmodule HTTPSanitizer do
  def sanitize_path(path) do
    String.replace(path,"..","") # replace .. by empty string
  end
end
