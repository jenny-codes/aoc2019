defmodule SpaceShip do
  def to_instruction_lists(input) do
    File.read!(input)
    |> String.split()
    |> Enum.map(fn line ->
      String.split(line, ",", trim: true)
      |> Enum.map(fn
        "U" <> num -> {:u, String.to_integer(num)}
        "R" <> num -> {:r, String.to_integer(num)}
        "D" <> num -> {:d, String.to_integer(num)}
        "L" <> num -> {:l, String.to_integer(num)}
      end)
    end)
  end

  def calculate_nearest_intersection_distance(intersections) do
    intersections
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  # -----------------------------------------------------------------
  # draw_board([head | instructions], {current_location}, [board])/3
  # -----------------------------------------------------------------

  # first entry
  def draw_board(instructions) do
    draw_board(instructions, {0, 0}, [])
  end

  # finished all instructions
  def draw_board([], _, board) do
    MapSet.new(board)
  end

  # finished traversing current instruction
  def draw_board([{_, 0} | instructions], current_pos, board) do
    draw_board(instructions, current_pos, board)
  end

  # traversing current instruction
  def draw_board([{dir, dis} | instructions], {x, y}, board) do
    new_pos =
      case dir do
        :u -> {x, y + 1}
        :d -> {x, y - 1}
        :r -> {x + 1, y}
        :l -> {x - 1, y}
      end

    draw_board([{dir, dis - 1} | instructions], new_pos, [new_pos | board])
  end
end

SpaceShip.to_instruction_lists('input/day_03.txt')
|> Enum.map(&SpaceShip.draw_board/1)
|> (fn [board1, board2] -> MapSet.intersection(board1, board2) end).()
|> SpaceShip.calculate_nearest_intersection_distance()
|> IO.puts()
