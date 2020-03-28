defmodule Spaceship.Puzzles do
  def day_05(input: input) do
    File.read!('../input/day_05.txt')
    |> Spaceship.Component.Intcode.build_program
    |> Spaceship.Component.Intcode.execute(0, [input])
  end

  def day_07 do
    program = File.read!('../input/day_07.txt')
    |> Spaceship.Component.Intcode.build_program

    [0,1,2,3,4]
    |> Spaceship.Util.permutations
    |> Enum.map(&Spaceship.Component.AmplificationCircuit.execute_program_in_sequence(program, &1))
    |> Enum.max
  end
end