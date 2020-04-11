defmodule Spaceship.Component.MonitoringStation do
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

  def draw_directions(asteroids) do
    asteroids
    |> Enum.map(fn ast ->
      dirs =
        asteroids
        |> MapSet.delete(ast)
        |> Enum.map(&calculate_vector_direction(ast, &1))
        |> MapSet.new()

      {ast, dirs}
    end)
    |> Map.new()
  end

  def calculate_vector_direction({x1, y1}, {x2, y2}) do
    with {x, y} when not (x == 0 or y == 0) <- {x2 - x1, y2 - y1} do
      Integer.gcd(x, y) |> (fn gcd -> {div(x, gcd), div(y, gcd)} end).()
    else
      {0, 0} -> {0, 0}
      {0, y} -> {0, div(y, abs(y))}
      {x, 0} -> {div(x, abs(x)), 0}
    end
  end
end
