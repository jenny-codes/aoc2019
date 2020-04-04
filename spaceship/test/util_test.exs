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

  test "str_sequence_into_index_map with default comma delimiter" do
    str_sequence = "1,2,3"
    expected_output = %{0 => 1, 1 => 2, 2 => 3}

    assert Spaceship.Util.str_sequence_into_index_map(str_sequence) == expected_output
  end

  test "str_sequence_into_index_map removes whitespaces in the result" do
    str_sequence = "1, 2, 3 "
    expected_output = %{0 => 1, 1 => 2, 2 => 3}

    assert Spaceship.Util.str_sequence_into_index_map(str_sequence) == expected_output
  end

  test "str_sequence_into_index_map with delimiter specified" do
    str_sequence = "1 2 3"
    expected_output = %{0 => 1, 1 => 2, 2 => 3}

    assert Spaceship.Util.str_sequence_into_index_map(str_sequence, " ") == expected_output
  end

  test "index_map_into_str_sequence with default comma delimiter" do
    index_map = %{0 => 1, 1 => 2, 2 => 3}
    expected_output = "1,2,3"

    assert Spaceship.Util.index_map_into_str_sequence(index_map), expected_output
  end

  test "index_map_into_str_sequence with delimiter specified" do
    index_map = %{0 => 1, 1 => 2, 2 => 3}
    expected_output = "1 2 3"

    assert Spaceship.Util.index_map_into_str_sequence(index_map, " "), expected_output
  end

  test "next_in_list returns the next item in a list" do
    list = [1, 2, 3]

    assert Spaceship.Util.next_in_list(list, 1) == 2
    assert Spaceship.Util.next_in_list(list, 2) == 3
    assert Spaceship.Util.next_in_list(list, 3) == 1
  end

  test "count_items turns a list into a map with unique values as key and occurances as value" do
    list = [1, 2, 3, 3, 3, 2]
    expected_output = %{1 => 1, 2 => 2, 3 => 3}

    assert Spaceship.Util.count_items(list) == expected_output
  end

  test "count_items returns an empty map given an empty list" do
    assert Spaceship.Util.count_items([]) == %{}
  end
end
