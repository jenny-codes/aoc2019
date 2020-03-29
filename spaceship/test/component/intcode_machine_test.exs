defmodule Spaceship.Component.IntcodeMachineTest do
  use ExUnit.Case, async: true

  test "#build_program returns an instruction map with index as key" do
    input = "1,2,3"
    expected_output = %{0 => 1, 1 => 2, 2 => 3}

    assert Spaceship.Component.IntcodeMachine.build_program(input) == expected_output
  end
end
