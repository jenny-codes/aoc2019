defmodule Spaceship.AmplificationCircuitTest do
  use ExUnit.Case

  setup do
    Supervisor.terminate_child(Spaceship.Supervisor, Spaceship.AmplifierSupervisor)
    Supervisor.restart_child(Spaceship.Supervisor, Spaceship.AmplifierSupervisor)
    :ok
  end

  describe "init_amplifier/2" do
    # function args: {phase_setting, index}, initial_input
    test "starts a named Amplifier process" do
      {pid, name} = Spaceship.AmplificationCircuit.init_amplifier({0, 0}, 0)

      %{active: active_process_count} =
        DynamicSupervisor.count_children(Spaceship.AmplifierSupervisor)

      assert active_process_count == 1
      assert Registry.keys(Spaceship.AmplifierRegistry, pid) == [name]
    end

    test "when index is 0 returns an Amplifier with init input as first input signal" do
      {pid, _name} = Spaceship.AmplificationCircuit.init_amplifier({1, 0}, 2)

      # There should be two items in the inbox: phase_setting (1) and initial_input (2)
      assert Spaceship.Component.Amplifier.check_signal(pid) == 1
      assert Spaceship.Component.Amplifier.check_signal(pid) == 2
      assert Spaceship.Component.Amplifier.check_signal(pid) == :no_signal
    end

    test "when index != 0 returns an Amplifier without initial input signal" do
      {pid, _name} = Spaceship.AmplificationCircuit.init_amplifier({3, 1}, 2)

      # There should be only one item in the inbox: phase_setting (3)
      assert Spaceship.Component.Amplifier.check_signal(pid) == 3
      assert Spaceship.Component.Amplifier.check_signal(pid) == :no_signal
    end
  end

  describe "init/2" do
    test "starts one Amplifier with 1-item sequence" do
      amp_list = Spaceship.AmplificationCircuit.init("1", 0)
      [{pid, name}] = amp_list

      %{active: active_process_count} =
        DynamicSupervisor.count_children(Spaceship.AmplifierSupervisor)

      assert length(amp_list) == 1
      assert active_process_count == 1
      assert Registry.keys(Spaceship.AmplifierRegistry, pid) == [name]
    end

    test "starts Amplifiers according to sequence length" do
      amp_list = Spaceship.AmplificationCircuit.init("1,2,3", 0)

      %{active: active_process_count} =
      DynamicSupervisor.count_children(Spaceship.AmplifierSupervisor)

      assert length(amp_list) == 3
      assert active_process_count == 3
    end

    test "passes intial_input to the first Amplifier" do
      [{pid, _amp_name}] = Spaceship.AmplificationCircuit.init("1", "initial_input")

      assert Spaceship.Component.Amplifier.check_signal(pid) == 1
      assert Spaceship.Component.Amplifier.check_signal(pid) == "initial_input"
    end
  end
end
