defmodule Spaceship.Puzzles do
  def day_05(input: input) do
    input_fn = fn opts ->
      [input_val | updated_input_args] = opts[:input_args]
      {input_val, Keyword.put(opts, :input_args, updated_input_args)}
    end

    File.read!('../input/day_05.txt')
    |> Spaceship.Component.IntcodeMachine.build_program
    |> Spaceship.Component.IntcodeMachine.execute(input_fn: input_fn, input_args: [input])
  end

  def day_07 do
    program = File.read!('../input/day_07.txt')
    |> Spaceship.Component.IntcodeMachine.build_program

    [0,1,2,3,4]
    |> Spaceship.Util.permutations
    |> Enum.map(&Spaceship.AmplificationCircuit.execute_program_in_sequence(program, &1))
    |> Enum.max
  end
end
