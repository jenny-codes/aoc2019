defmodule Spaceship.Server.AmplifierTest do
  use ExUnit.Case, async: true

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
end
