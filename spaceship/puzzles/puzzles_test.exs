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

  # test "day_05 part 1" do
  #   expected_answer = 13_294_380
  #   assert Spaceship.Puzzles.day_05(input: 1) == expected_answer
  # end

  test "day_05 part 2" do
    assert Spaceship.Puzzles.day_05(input: 5) == 11_460_760
  end

  test "day_07 part 1" do
    assert Spaceship.Puzzles.day_07() == 17440
  end

  test "day_07 case 1" do
    sequence = [4, 3, 2, 1, 0]

    output =
      "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"
      |> Spaceship.Component.IntcodeMachine.build_program()
      |> Spaceship.AmplificationCircuit.execute_program_in_sequence(sequence)

    assert output == 43210
  end

  test "day_07 case 2" do
    sequence = [0, 1, 2, 3, 4]

    output =
      "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
      |> Spaceship.Component.IntcodeMachine.build_program()
      |> Spaceship.AmplificationCircuit.execute_program_in_sequence(sequence)

    assert output == 54321
  end

  test "day_07 case 3" do
    sequence = [1, 0, 4, 3, 2]

    output =
      "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
      |> Spaceship.Component.IntcodeMachine.build_program()
      |> Spaceship.AmplificationCircuit.execute_program_in_sequence(sequence)

    assert output == 65210
  end

  test "day_07_2 case 1" do
    sequence = "9,8,7,6,5"
    program_str = "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"

    output = Spaceship.Puzzles.day_07_2(sequence, program_str)

    assert output == 139_629_729
  end

  test "day07 real" do
    program_str = File.read!('input/day_07.txt')

    [5, 6, 7, 8, 9]
    |> Spaceship.Util.permutations()
    |> Enum.map(&day_07_2(Enum.join(&1, ","), program_str))
    |> Enum.max()
  end
    assert Spaceship.Puzzles.play == 2
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
