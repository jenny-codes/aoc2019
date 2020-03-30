defmodule Spaceship.AmplificationCircuit do
  # INITIAL_INPUT = 0

  def execute_program_in_sequence(program, sequence) do
    Enum.reduce(sequence, 0, fn cur, previous_output ->
      Spaceship.Component.IntcodeMachine.execute(program, 0, [cur, previous_output])
    end)
  end
end
