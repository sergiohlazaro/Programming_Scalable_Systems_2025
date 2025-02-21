defmodule Exercises2Test do
  use ExUnit.Case
  doctest Exercises2

  test "greets the world" do
    assert Exercises2.hello() == :world
  end
end
