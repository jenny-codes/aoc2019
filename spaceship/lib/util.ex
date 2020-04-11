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

  def next_in_list(list, item) do
    next_item(list ++ [hd(list)], item)
  end

  defp next_item([head | tail], item) when head == item do
    hd(tail)
  end

  defp next_item([_head | tail], item) do
    next_item(tail, item)
  end

  def count_items(list) do
    Enum.reduce(list, %{}, fn item, acc ->
      new_value =
        if acc[item] do
          acc[item] + 1
        else
          1
        end

      Map.put(acc, item, new_value)
    end)
  end

  def apply_if(item, bool, func) when is_function(bool) do
    if bool.(item) do
      func.(item)
    else
      item
    end
  end

  def apply_if(item, bool, func) do
    if bool do
      func.(item)
    else
      item
    end
  end
end
