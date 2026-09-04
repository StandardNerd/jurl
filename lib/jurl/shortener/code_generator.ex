defmodule Jurl.Shortener.CodeGenerator do
  @alphabet ~c"abcdefghijklmnopqrstuvwxyz0123456789"
  @length 3

  def generate do
    1..@length
    |> Enum.map(fn _ -> Enum.random(@alphabet) end)
    |> List.to_string()
  end
end
