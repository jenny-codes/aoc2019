ExUnit.start()

defmodule Spaceship.PuzzlesTest do
  use ExUnit.Case

  setup do
    # TODO: find a proper way to reset supervisors in tests
    Supervisor.terminate_child(Spaceship.Supervisor, Spaceship.AmplifierSupervisor)
    Supervisor.restart_child(Spaceship.Supervisor, Spaceship.AmplifierSupervisor)
    Supervisor.terminate_child(Spaceship.Supervisor, Spaceship.RunProgramTaskSupervisor)
    Supervisor.restart_child(Spaceship.Supervisor, Spaceship.RunProgramTaskSupervisor)
    :ok
  end

  describe "day 05" do
    test "part 2" do
      IO.puts(Spaceship.Puzzles.day05_2(input: 5))
    end
  end

  describe "day 07" do
    @tag timeout: :infinity
    test "part 2" do
      program_str = File.read!('puzzles/input/day_07.txt')

      [5, 6, 7, 8, 9]
      |> Spaceship.Util.permutations()
      |> Enum.map(&Spaceship.Puzzles.day07_2(Enum.join(&1, ","), program_str))
      |> Enum.max()
      |> IO.puts()
    end

    test "part 2 exercise 1" do
      sequence = "9,8,7,6,5"

      program_str =
        "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"

      output = Spaceship.Puzzles.day07_2(sequence, program_str)

      assert output == 139_629_729
    end
  end

  describe "day 08" do
    test "part 1" do
      File.read!('puzzles/input/day_08.txt')
      |> Spaceship.Puzzles.day08_1({25, 6})
      |> IO.puts()
    end

    test "part 2" do
      File.read!('puzzles/input/day_08.txt')
      |> Spaceship.Puzzles.day08_2({25, 6})
      |> IO.puts()
    end
  end

  describe "day 09" do
    test "part 1 exercise 1: outputs a copy of itself" do
      Spaceship.Puzzles.day09("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99")
    end

    test "part 1 exercise 2: outputs a 16-digit number" do
      output = Spaceship.Puzzles.day09("1102,34915192,34915192,7,4,7,99,0")

      assert output == 1_219_070_632_396_864
    end

    test "part 1 exercise 3: outputs the large number in the middle" do
      output = Spaceship.Puzzles.day09("104,1125899906842624,99")

      assert output == 1_125_899_906_842_624
    end

    test "part 1" do
      File.read!('puzzles/input/day_09.txt')
      |> Spaceship.Puzzles.day09(1)
    end

    test "part 2" do
      File.read!('puzzles/input/day_09.txt')
      |> Spaceship.Puzzles.day09(2)
    end
  end

  describe "day 10" do
    test "part 1 exercise 1" do
      asteroid_map_str = "......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####"

      Spaceship.Puzzles.day10(asteroid_map_str)
    end

    test "part 1" do
      File.read!('puzzles/input/day_10.txt')
      |> Spaceship.Puzzles.day10()
    end
  end
end
