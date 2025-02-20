defmodule Sheet1 do
  def match_123([1, 2, 3 | tail]), do: tail

  def match_string("Hello " <> name), do: name

  def match_1234([1, 2, 3] ++ tail), do: tail
end
