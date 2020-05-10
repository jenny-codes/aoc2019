defmodule Spaceship.Component.MonitoringStation do
  alias Spaceship.Util

  def from_input(asteriod_map_str) do
    asteriod_map_str
    |> String.split("\n", trim: true)
    |> Stream.with_index()
    |> Stream.flat_map(fn {mark_str, y_idx} ->
      mark_str
      |> String.split("", trim: true)
      |> Stream.with_index()
      |> (fn row ->
            for {"#", x_idx} <- row do
              {x_idx, y_idx}
            end
          end).()
    end)
    |> Enum.to_list()
    |> MapSet.new()
  end

  @doc """
  Draws a map where key is each asteroid's coordinate and value is a map containing the direction as key and a list of asteroid coordinates in that direction as value.
  """
  def direction_map(asteroids) do
    asteroids
    |> Enum.map(fn ast ->
      dirs =
        asteroids
        |> MapSet.delete(ast)
        |> Enum.map(&direction(ast, &1))
        |> MapSet.new()

      {ast, dirs}
    end)
    |> Map.new()
  end

  def find_laser_target(ast_map, target) do
    find_target(ast_map, target, {0, 0}, 1)
  end

  def find_target(ast_map, target, {i, j}, count) do
    if ast_map[i][j] do
      if count == target do
        ast_map[i][j]
      else
        find_target(ast_map, target, {i + 1, j}, count + 1)
      end
    else
      if i == map_size(ast_map) do
        find_target(ast_map, target, {0, j + 1}, count)
      else
        find_target(ast_map, target, {i + 1, j}, count)
      end
    end
  end

  def direction_and_distance_map(ast_list, ast) do
    ast_list
    |> Enum.reject(&(&1 == ast))
    |> Enum.reduce(%{}, fn other_ast, acc ->
      dir = direction(ast, other_ast)
      dis = distance(ast, other_ast)

      Map.put(acc, dir, [{other_ast, dis} | acc[dir] || []])
    end)

    |> Enum.map(fn {dir, other_asts_with_distance} ->
      # a list of {ast, distance}
      ordered_asts =
        other_asts_with_distance
        # sort by distance
        |> Enum.sort_by(&elem(&1, 1))
        |> Util.to_indexed_map(&elem(&1, 0))

      {dir, ordered_asts}
    end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Util.to_indexed_map(&elem(&1, 1))
  end

  def direction({from_x, from_y}, {to_x, to_y}) do
    {to_x - from_x, -(to_y - from_y)} |> Util.vector_to_angle(clockwise: true, offset: 90)
  end

  def distance({from_x, from_y}, {to_x, to_y}) do
    {to_x - from_x, to_y - from_y} |> Util.vector_to_distance()
  end
end
