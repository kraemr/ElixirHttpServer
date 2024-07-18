defmodule HttpServerAppTest do
  use ExUnit.Case
  doctest HttpServerApp

  test "greets the world" do
    assert HttpServerApp.hello() == :world
  end
end
