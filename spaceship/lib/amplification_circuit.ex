defmodule Spaceship.AmplificationCircuit do
  def init(phase_setting_sequence, initial_input) do
    phase_setting_sequence
    |> Spaceship.Util.str_sequence_into_index_map()
    |> Enum.map(&init_amplifier(&1, initial_input))
  end

  def run(amp_list, program_str) do
    amp_list
    |> Enum.map(&run_amplifier(&1, program_str, amp_list))
    |> Enum.each(fn {:ok, amp} -> await_finish(amp) end)

    # The final output is sent to the first amplifier, so we check its inbox again
    # to get the value and return.
    Enum.at(amp_list, 0)
    |> Spaceship.Server.Amplifier.check_signal()
  end

  def init_amplifier({index, phase_setting}, initial_input) when index == 0 do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        Spaceship.AmplifierSupervisor,
        {Spaceship.Server.Amplifier, inbox: [phase_setting, initial_input]}
      )

    pid
  end

  def init_amplifier({_index, phase_setting}, _initial_input) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        Spaceship.AmplifierSupervisor,
        {Spaceship.Server.Amplifier, inbox: [phase_setting]}
      )

    pid
  end

  def run_amplifier(amp, program_str, amp_list) do
    input_fn = fn opts ->
      {await_signal(amp), opts}
    end

    output_fn = fn output_val ->
      Spaceship.Server.Amplifier.send_signal(next_amp_for(amp, amp_list), output_val)
      :continue
    end

    # Start the async task
    run_status =
      Spaceship.Server.Amplifier.run(
        amp,
        program_str,
        input_fn: input_fn,
        output_fn: output_fn
      )

    {run_status, amp}
  end

  def await_finish(amp) do
    case Spaceship.Server.Amplifier.check_result(amp) do
      :no_result ->
        Process.sleep(100)
        await_finish(amp)

      :finished ->
        :ok
    end
  end

  defp next_amp_for(current_amp, amp_list) do
    Spaceship.Util.next_in_list(amp_list, current_amp)
  end

  defp await_signal(amp) do
    case Spaceship.Server.Amplifier.check_signal(amp) do
      :no_signal ->
        Process.sleep(100)
        await_signal(amp)

      value ->
        value
    end
  end
end
