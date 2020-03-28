defmodule Spaceship.PuzzlesTest do
  use ExUnit.Case, async: true

  # test "day_05 part 1" do
  #   expected_answer = 13_294_380
  #   assert Spaceship.Puzzles.day_05(input: 1) == expected_answer
  # end

  test "day_05 part 2" do
    assert Spaceship.Puzzles.day_05(input: 5) == 11_460_760
  end

  test "day_07 part 1" do
    assert Spaceship.Puzzles.day_07() == 17440
  end
end
