defmodule Spaceship.Puzzles do
  def day05_2(program_str, input: input) do
    input_fn = fn opts ->
      [input_val | updated_input_args] = opts[:input_args]
      {input_val, Keyword.put(opts, :input_args, updated_input_args)}
    end

    output_fn = fn _output_val -> :return end

    program_str
    |> Spaceship.Component.IntcodeMachine.build_program()
    |> Spaceship.Component.IntcodeMachine.execute(
      input_fn: input_fn,
      input_args: [input],
      output_fn: output_fn
    )
  end

  def day07_2(phase_setting_sequence, program_str) do
    phase_setting_sequence
    |> Spaceship.AmplificationCircuit.init(0)
    |> Spaceship.AmplificationCircuit.run(program_str)
  end
end
