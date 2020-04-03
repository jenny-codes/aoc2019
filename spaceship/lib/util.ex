defmodule Spaceship.Util do
  def permutations([]), do: [[]]

  def permutations(list) do
    for elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest]
  end

  def str_sequence_into_index_map(str_sequence, delimiter \\ ",") do
    str_sequence
    |> String.split(delimiter, trim: true)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index()
    |> Map.new(fn {x, i} -> {i, x} end)
  end

  def index_map_into_str_sequence(index_map, delimiter \\ ",") do
    index_map
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(&index_map[&1])
    |> Enum.join(delimiter)
  end
end
