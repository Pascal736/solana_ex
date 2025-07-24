defmodule SolanaExTest do
  use ExUnit.Case
  doctest SolanaEx

  test "greets the world" do
    assert SolanaEx.hello() == :world
  end
end
