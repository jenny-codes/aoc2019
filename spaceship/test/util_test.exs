defmodule Spaceship.UtilTest do
  use ExUnit.Case, async: true

  test 'permutations with empty list returns empty nested list' do
    assert Spaceship.Util.permutations([]) == [[]]
  end

  test 'permutations returns permutations of a list' do
    assert length(Spaceship.Util.permutations([1])) == 1
    assert length(Spaceship.Util.permutations([1, 2])) == 2
    assert length(Spaceship.Util.permutations([1, 2, 3])) == 6
  end
end
