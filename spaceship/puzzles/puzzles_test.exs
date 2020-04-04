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
      IO.puts Spaceship.Puzzles.day05_2(input: 5)
    end
  end

  describe "day 07" do
    test "part 2" do
      program_str = File.read!('input/day_07.txt')

      [5, 6, 7, 8, 9]
      |> Spaceship.Util.permutations()
      |> Enum.map(&day_07_2(Enum.join(&1, ","), program_str))
      |> Enum.max()
      |> IO.puts()
    end

    test "part 2 exercise 1" do
      sequence = "9,8,7,6,5"

      program_str =
        "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"

      output = Spaceship.Puzzles.day_07_2(sequence, program_str)

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
end
