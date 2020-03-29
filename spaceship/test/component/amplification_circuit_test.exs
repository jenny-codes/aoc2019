defmodule Spaceship.Component.AmplificationCircuitTest do
  use ExUnit.Case, async: true

  test "day_07 case 1" do
    sequence = [4, 3, 2, 1, 0]

    output =
      "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"
      |> Spaceship.Component.IntcodeMachine.build_program()
      |> Spaceship.Component.AmplificationCircuit.execute_program_in_sequence(sequence)

    assert output == 43210
  end

  test "day_07 case 2" do
    sequence = [0, 1, 2, 3, 4]

    output =
      "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
      |> Spaceship.Component.IntcodeMachine.build_program()
      |> Spaceship.Component.AmplificationCircuit.execute_program_in_sequence(sequence)

    assert output == 54321
  end

  test "day_07 case 3" do
    sequence = [1, 0, 4, 3, 2]

    output =
      "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
      |> Spaceship.Component.IntcodeMachine.build_program()
      |> Spaceship.Component.AmplificationCircuit.execute_program_in_sequence(sequence)

    assert output == 65210
  end
end
