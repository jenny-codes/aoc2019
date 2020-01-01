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
    |> Stream.map(fn {k, _} -> fetch_individual_orbit_chain_for(k, data_map) end)
    |> Stream.map(&length/1)
    |> Enum.sum()
  end

  def count_orbital_transfers_between(obj1, obj2, data_map) do
    count_mapset_differences = fn [set1, set2] ->
      MapSet.difference(MapSet.union(set1, set2), MapSet.intersection(set1, set2))
      |> MapSet.size()
    end

    [obj1, obj2]
    |> Enum.map(&fetch_individual_orbit_chain_for(&1, data_map))
    |> Enum.map(&MapSet.new/1)
    |> count_mapset_differences.()
  end

  def fetch_individual_orbit_chain_for(node, data_map, chain \\ []) do
    parent_node = data_map[node]

    case parent_node do
      nil -> chain
      _ -> fetch_individual_orbit_chain_for(parent_node, data_map, [parent_node | chain])
    end
  end
end

# Part 1
'input/day_06.txt'
|> Orbit.draw_map_from_input()
|> Orbit.count_total_orbits()
|> IO.puts()

# Part2
'input/day_06.txt'
|> Orbit.draw_map_from_input()
|> (fn data -> Orbit.count_orbital_transfers_between("YOU", "SAN", data) end).()
|> IO.puts()
