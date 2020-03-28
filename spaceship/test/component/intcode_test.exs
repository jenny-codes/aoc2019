defmodule Spaceship.Component.IntcodeTest do
  use ExUnit.Case, async: true

  test "#build_program returns an instruction map with index as key" do
    input = "1,2,3"
    expected_output = %{0 => 1, 1 => 2, 2 => 3}

    assert Spaceship.Component.Intcode.build_program(input) == expected_output
  end
end
