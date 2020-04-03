defmodule Spaceship.AmplificationCircuitTest do
  use ExUnit.Case

  setup do
    # TODO: find a proper way to reset supervisors in tests
    Supervisor.terminate_child(Spaceship.Supervisor, Spaceship.AmplifierSupervisor)
    Supervisor.restart_child(Spaceship.Supervisor, Spaceship.AmplifierSupervisor)
    Supervisor.terminate_child(Spaceship.Supervisor, Spaceship.RunProgramTaskSupervisor)
    Supervisor.restart_child(Spaceship.Supervisor, Spaceship.RunProgramTaskSupervisor)
    :ok
  end

  describe "init_amplifier/2" do
    # function args: {phase_setting, index}, initial_input
    test "starts a named Amplifier process" do
      Spaceship.AmplificationCircuit.init_amplifier({0, 0}, 0)

      %{active: active_process_count} =
        DynamicSupervisor.count_children(Spaceship.AmplifierSupervisor)

      assert active_process_count == 1
    end

    test "when index is 0 returns an Amplifier with init input as first input signal" do
      pid = Spaceship.AmplificationCircuit.init_amplifier({0, 1}, 2)

      # There should be two items in the inbox: phase_setting (1) and initial_input (2)
      assert Spaceship.Server.Amplifier.check_signal(pid) == 1
      assert Spaceship.Server.Amplifier.check_signal(pid) == 2
      assert Spaceship.Server.Amplifier.check_signal(pid) == :no_signal
    end

    test "when index != 0 returns an Amplifier without initial input signal" do
      pid = Spaceship.AmplificationCircuit.init_amplifier({1, 3}, 2)

      # There should be only one item in the inbox: phase_setting (3)
      assert Spaceship.Server.Amplifier.check_signal(pid) == 3
      assert Spaceship.Server.Amplifier.check_signal(pid) == :no_signal
    end
  end

  describe "init/2" do
    test "starts one Amplifier with 1-item sequence" do
      [pid] = Spaceship.AmplificationCircuit.init("1", 0)

      %{active: active_process_count} =
        DynamicSupervisor.count_children(Spaceship.AmplifierSupervisor)

      [{:undefined, working_pid, :worker, _server}] =
        DynamicSupervisor.which_children(Spaceship.AmplifierSupervisor)

      assert working_pid == pid
      assert active_process_count == 1
    end

    test "starts Amplifiers according to sequence length" do
      amp_list = Spaceship.AmplificationCircuit.init("1,2,3", 0)

      %{active: active_process_count} =
        DynamicSupervisor.count_children(Spaceship.AmplifierSupervisor)

      assert length(amp_list) == 3
      assert active_process_count == 3
    end

    test "passes intial_input to the first Amplifier" do
      [pid] = Spaceship.AmplificationCircuit.init("1", "initial_input")

      assert Spaceship.Server.Amplifier.check_signal(pid) == 1
      assert Spaceship.Server.Amplifier.check_signal(pid) == "initial_input"
    end
  end

  describe "run_amplifier/3" do
    test "works" do
      # This setup will make the amplifier
      [amp] = Spaceship.AmplificationCircuit.init("111", 333)
      {return_status, _task_pid} = Spaceship.AmplificationCircuit.run_amplifier(amp, "99", [amp])

      assert return_status == :ok
    end
  end
end
