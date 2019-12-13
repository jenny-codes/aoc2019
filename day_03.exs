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
  def calculate_nearest_intersection_distance([board1, board2]) do
    MapSet.intersection(board1, board2)
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  # puzzle 2
  def calculate_intersection_with_fewest_steps([board1, board2]) do
    [board1, board2]
    |> Enum.map(&Map.keys/1)
    |> Enum.map(&MapSet.new/1)
    |> (fn [set1, set2] -> MapSet.intersection(set1, set2) end).()
    |> Enum.map(fn key -> board1[key] + board2[key] end)
    |> Enum.min()
  end

  # -----------------------------------------------------------------
  # draw_board_with_steps([instructions], {current_location}, steps, %{board})/3
  # -----------------------------------------------------------------

  # first entry
  def draw_board_with_steps(instructions) do
    draw_board_with_steps(instructions, {0, 0}, 0, Map.new())
  end

  # finish all instructions
  def draw_board_with_steps([], _, _, board) do
    board
  end

  # finished traversing current instruction
  def draw_board_with_steps([{_, 0} | instructions], current_pos, steps, board) do
    draw_board_with_steps(instructions, current_pos, steps, board)
  end

  # traversing current instructions
  def draw_board_with_steps([{dir, dis} | instructions], {x, y}, steps, board) do
    new_pos =
      case dir do
        :u -> {x, y + 1}
        :d -> {x, y - 1}
        :r -> {x + 1, y}
        :l -> {x - 1, y}
      end

    draw_board_with_steps(
      [{dir, dis - 1} | instructions],
      new_pos,
      steps + 1,
      Map.put_new(board, new_pos, steps + 1)
    )
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

# puzzle 1
SpaceShip.to_instruction_lists('input/day_03.txt')
|> Enum.map(&SpaceShip.draw_board/1)
|> SpaceShip.calculate_nearest_intersection_distance()
|> (fn answer -> IO.puts("puzzle 1: #{answer}") end).()

# puzzle 2
SpaceShip.to_instruction_lists('input/day_03.txt')
|> Enum.map(&SpaceShip.draw_board_with_steps/1)
|> SpaceShip.calculate_intersection_with_fewest_steps()
|> (fn answer -> IO.puts("puzzle 2: #{answer}") end).()
