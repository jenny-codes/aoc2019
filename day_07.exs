# require '../day_05.exs'

defmodule AmplificationCircuit do
  # INITIAL_INPUT = 0
  def find_max_output_value_in(permutations, program) do
    Enum.reduce(permutations, 0, fn permutation, acc ->
      output = output_value_with_phase_setting_sequence(permutation, program)
      cond do
        output > acc -> output
        output <= acc -> acc
      end
    end)
  end

  def output_value_with_phase_setting_sequence(sequence, program) do
    Enum.reduce(sequence, 0, fn phase_setting, previous_output ->
      Intcode.execute(phase_setting, inputs: [ phase_setting, previous_output ])
    end)
  end
end

defmodule Util do
  def permutations([]), do: [[]]

  def permutations(list) do
    for elem <- list, rest <- permutations(list--[elem]), do: [elem|rest]
  end
end

program = Intcode.get_input_to_map('input/day_07.txt')

# [0,1,2,3,4]
# |> Util.permutations
# |> AmplificationCircuit.find_max_output_value_in(program)
