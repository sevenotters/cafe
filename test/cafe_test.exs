defmodule CafeTest do
  use ExUnit.Case
  doctest Cafe

  test "greets the world" do
    assert Cafe.hello() == :world
  end
end
