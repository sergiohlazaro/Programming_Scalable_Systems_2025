defmodule Exercises1Test do
  use ExUnit.Case
  doctest Exercises1

  test "greets the world" do
    assert Exercises1.hello() == :world
  end
end
