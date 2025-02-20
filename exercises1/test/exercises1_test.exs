defmodule Sheet1Test do
  use ExUnit.Case

  test "match_123 works correctly" do
    assert Sheet1.match_123([1, 2, 3, 4, 5]) == [4, 5]
  end

  test "match_string works correctly" do
    assert Sheet1.match_string("Hello world") == "world"
  end
end

