defmodule Spaceship.AmplificationCircuit do
  # INITIAL_INPUT = 0

  def init(phase_setting_sequence, initial_input) do
    phase_setting_sequence
    |> normalize_with_index
    |> Enum.map(&Spaceship.AmplificationCircuit.init_amplifier(&1, initial_input))
  end

  def init_amplifier({phase_setting, index}, initial_input) when index == 0 do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        Spaceship.AmplifierSupervisor,
        {
          Spaceship.Server.Amplifier,
          inbox: [phase_setting, initial_input], name: via_tuple(amp_name(index))
        }
      )

    {pid, amp_name(index)}
  end

  def init_amplifier({phase_setting, index}, _initial_input) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        Spaceship.AmplifierSupervisor,
        {
          Spaceship.Server.Amplifier,
          inbox: [phase_setting], name: via_tuple(amp_name(index))
        }
      )

    {pid, amp_name(index)}
  end

  def execute_program_in_sequence(program, sequence) do
    input_fn = fn opts ->
      [input_val | updated_input_args] = opts[:input_args]
      {input_val, Keyword.put(opts, :input_args, updated_input_args)}
    end

    output_fn = fn(_val) -> :return end

    Enum.reduce(sequence, 0, fn cur, previous_output ->
      Spaceship.Component.IntcodeMachine.execute(
        program,
        input_fn: input_fn,
        input_args: [cur, previous_output],
        output_fn: output_fn
      )
    end)
  end

  defp amp_name(index) do
    "amp_#{index}"
  end

  defp via_tuple(name) do
    {:via, Registry, {Spaceship.AmplifierRegistry, name}}
  end

  defp normalize_with_index(str) do
    str
    |> String.split(",", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index()
  end
end
