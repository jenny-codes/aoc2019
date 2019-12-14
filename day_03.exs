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

  # puzzle 1
  def calculate_nearest_intersection_distance(boards) do
    boards
    |> Enum.map(&MapSet.new/1)
    |> fn [b1, b2] -> MapSet.intersection(b1, b2) end.()
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  # puzzle 2
  def calculate_intersection_with_fewest_steps([board1, board2]) do
    [board1, board2]
    |> Enum.map(&MapSet.new/1)
    |> fn [b1, b2] -> MapSet.intersection(b1, b2) end.()
    |> Enum.map(fn coord ->
      b1_steps = Enum.find_index(board1, fn pos -> pos == coord end) + 1
      b2_steps = Enum.find_index(board2, fn pos -> pos == coord end) + 1
      b1_steps + b2_steps
    end)
    |> Enum.min()
  end

  # -----------------------------------------------------------------
  # draw_board([instructions], {current_location}, [board])/3
  # -----------------------------------------------------------------
  # first entry
  def draw_board(instructions) do
    draw_board(instructions, {0, 0}, [])
  end

  # finished all instructions
  def draw_board([], _, board) do
    Enum.reverse(board)
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

# puzzle 1
SpaceShip.to_instruction_lists('input/day_03.txt')
|> Enum.map(&SpaceShip.draw_board/1)
|> SpaceShip.calculate_nearest_intersection_distance()
|> (fn answer -> IO.puts("puzzle 1: #{answer}") end).()

# puzzle 2
SpaceShip.to_instruction_lists('input/day_03.txt')
|> Enum.map(&SpaceShip.draw_board/1)
|> SpaceShip.calculate_intersection_with_fewest_steps()
|> (fn answer -> IO.puts("puzzle 2: #{answer}") end).()
