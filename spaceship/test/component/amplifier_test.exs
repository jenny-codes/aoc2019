defmodule Spaceship.Component.AmplifierTest do
  use ExUnit.Case, async: true

  test "#check_signal returns a signal if inbox is not empty" do
    {:ok, amp} = Spaceship.Component.Amplifier.start_link(inbox: ["a signal"])

    signal = Spaceship.Component.Amplifier.check_signal(amp)
    assert signal == "a signal"
  end

  test "#check_signal returns no_signal if inbox is empty" do
    {:ok, amp} = Spaceship.Component.Amplifier.start_link()

    signal = Spaceship.Component.Amplifier.check_signal(amp)
    assert signal == :no_signal
  end

  test "#check_signal removes singnals from the head of list" do
    {:ok, amp} = Spaceship.Component.Amplifier.start_link(inbox: ["signal1", "signal2"])

    signal1 = Spaceship.Component.Amplifier.check_signal(amp)
    signal2 = Spaceship.Component.Amplifier.check_signal(amp)

    assert signal1 == "signal1"
    assert signal2 == "signal2"
  end

  test "#send_signal stores a signal in the inbox" do
    {:ok, amp} = Spaceship.Component.Amplifier.start_link()

    Spaceship.Component.Amplifier.send_signal(amp, "a signal")
    signal = Spaceship.Component.Amplifier.check_signal(amp)

    assert signal == "a signal"
  end

  test "#send_signal stores signals in the right order" do
    {:ok, amp} = Spaceship.Component.Amplifier.start_link()
    Spaceship.Component.Amplifier.send_signal(amp, "signal 1")
    Spaceship.Component.Amplifier.send_signal(amp, "signal 2")

    signal1 = Spaceship.Component.Amplifier.check_signal(amp)
    signal2 = Spaceship.Component.Amplifier.check_signal(amp)

    assert signal1 == "signal 1"
    assert signal2 == "signal 2"
  end
end
