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

  def vector_to_angle({0, 0}, _options), do: 0

  def vector_to_angle(vector, options) do
    vector_to_angle(vector)
    |> apply_if(options[:offset], &(&1 - options[:offset]))
    |> apply_if(options[:clockwise], &(360 - &1))
    |> apply_if(&(&1 < 0), &(&1 + 360))
    |> apply_if(&(&1 >= 360), &(&1 - 360))
  end

  def vector_to_angle({x, y}) do
    (:math.atan2(y, x) * 180 / :math.pi())
    |> apply_if(&(&1 < 0), &(&1 + 360))
  end

  def vector_to_distance({x, y}) do
    (:math.pow(x, 2) + :math.pow(y, 2)) |> :math.sqrt()
  end

  def to_indexed_map(orig_list) do
    orig_list
    |> Enum.with_index()
    |> Map.new(fn {item, idx} -> {idx, item} end)
  end

  def to_indexed_map(orig_list, transformer) do
    orig_list
    |> Enum.with_index()
    |> Map.new(fn {item, idx} -> {idx, transformer.(item)} end)
  end
end
