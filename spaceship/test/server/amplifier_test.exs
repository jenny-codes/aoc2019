defmodule Spaceship.Server.AmplifierTest do
  use ExUnit.Case, async: true

  setup do
    # TODO: find a proper way to reset supervisors in tests
    Supervisor.terminate_child(Spaceship.Supervisor, Spaceship.RunProgramTaskSupervisor)
    Supervisor.restart_child(Spaceship.Supervisor, Spaceship.RunProgramTaskSupervisor)
    :ok
  end

  describe "check_signal/1" do
    test "returns a signal if inbox is not empty" do
      {:ok, amp} = Spaceship.Server.Amplifier.start_link(inbox: ["a signal"])

      signal = Spaceship.Server.Amplifier.check_signal(amp)
      assert signal == "a signal"
    end

    test "returns no_signal if inbox is empty" do
      {:ok, amp} = Spaceship.Server.Amplifier.start_link()

      signal = Spaceship.Server.Amplifier.check_signal(amp)
      assert signal == :no_signal
    end

    test "removes singnals from the head of list" do
      {:ok, amp} = Spaceship.Server.Amplifier.start_link(inbox: ["signal1", "signal2"])

      signal1 = Spaceship.Server.Amplifier.check_signal(amp)
      signal2 = Spaceship.Server.Amplifier.check_signal(amp)

      assert signal1 == "signal1"
      assert signal2 == "signal2"
    end
  end

  describe "send_signal/2" do
    test "stores a signal in the inbox" do
      {:ok, amp} = Spaceship.Server.Amplifier.start_link()

      Spaceship.Server.Amplifier.send_signal(amp, "a signal")
      signal = Spaceship.Server.Amplifier.check_signal(amp)

      assert signal == "a signal"
    end

    test "stores signals in the right order" do
      {:ok, amp} = Spaceship.Server.Amplifier.start_link()
      Spaceship.Server.Amplifier.send_signal(amp, "signal 1")
      Spaceship.Server.Amplifier.send_signal(amp, "signal 2")

      signal1 = Spaceship.Server.Amplifier.check_signal(amp)
      signal2 = Spaceship.Server.Amplifier.check_signal(amp)

      assert signal1 == "signal 1"
      assert signal2 == "signal 2"
    end
  end

  describe "run/3" do
    test "runs the given program to a task process" do
      {:ok, amp} = Spaceship.Server.Amplifier.start_link()
      result = Spaceship.Server.Amplifier.run(amp, "99", [])

      # 99 on IntcodeMachine should return immediately with 99
      assert result == :ok
      assert Spaceship.Server.Amplifier.check_result(amp) == :finished
    end

    test "runs the given program with options on IntcodeMachine" do
      {:ok, amp} = Spaceship.Server.Amplifier.start_link()

      input_fn = fn _opts -> {333, []} end

      # This program should take an input and place it to the first position,
      # which will be the return value when 99 is reached.
      Spaceship.Server.Amplifier.run(amp, "3,0,99", input_fn: input_fn)

      assert Spaceship.Server.Amplifier.check_result(amp) == :finished
    end

    test "provides input values from inbox when specified" do
      {:ok, amp} = Spaceship.Server.Amplifier.start_link(inbox: [333])

      input_fn = fn _opts ->
        {Spaceship.Server.Amplifier.check_signal(amp), []}
      end

      Spaceship.Server.Amplifier.run(amp, "3,0,99", input_fn: input_fn)

      assert ensure_result(amp) == :finished
    end
  end

  describe "check_result/1" do
    test "returns :no_signal when no result yet" do
      {:ok, amp} = Spaceship.Server.Amplifier.start_link()

      assert Spaceship.Server.Amplifier.check_result(amp) == :no_result
    end
  end

  def ensure_result(amp) do
    case Spaceship.Server.Amplifier.check_result(amp) do
      :no_result ->
        Process.sleep(100)
        ensure_result(amp)

      value ->
        value
    end
  end
end
