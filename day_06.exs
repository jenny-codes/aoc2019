defmodule Orbit do
  def draw_map_from_input(input) do
    input
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ")"))
    |> Map.new(fn [parent, child] -> {child, parent} end)
  end

  def count_total_orbits(data_map) do
    data_map
    |> Stream.map(fn {_, v} -> count_individual_orbits(data_map, v) end)
    |> Enum.sum()
  end

  def count_individual_orbits(data_map, node, count \\ 1) do
    case data_map[node] do
      nil -> count
      _ -> count_individual_orbits(data_map, data_map[node], count + 1)
    end
  end
end

'input/day_06.txt'
|> Orbit.draw_map_from_input()
|> Orbit.count_total_orbits()
|> IO.puts()
