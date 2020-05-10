defmodule Spaceship.UtilTest do
  use ExUnit.Case, async: true

  alias Spaceship.Util

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

  test "apply_if/3 apply the 3rd param to 1st param if 2nd param is true" do
    assert Util.apply_if(0, true, fn x -> x + 3 end) == 3
    assert Util.apply_if(0, false, fn x -> x + 3 end) == 0
  end

  test "apply_if/3 accepts a func as 2nd param" do
    assert Util.apply_if(0, &(&1 == 0), &(&1 + 3)) == 3
    assert Util.apply_if(0, &(&1 != 0), &(&1 + 3)) == 0
  end

  test "vector_to_angle/1 transforms a vector to angle" do
    assert Util.vector_to_angle({0, 0}) == 0
    assert Util.vector_to_angle({1, 0}) == 0
    assert Util.vector_to_angle({0, 1}) == 90
    assert Util.vector_to_angle({-1, 0}) == 180
    assert Util.vector_to_angle({0, -1}) == 270
  end

  test "vector_to_angle/2 when clockwise" do
    assert Util.vector_to_angle({0, 0}, clockwise: true) == 0
    assert Util.vector_to_angle({1, 0}, clockwise: true) == 0
    assert Util.vector_to_angle({0, 1}, clockwise: true) == 270
    assert Util.vector_to_angle({-1, 0}, clockwise: true) == 180
    assert Util.vector_to_angle({0, -1}, clockwise: true) == 90
  end

  test "vector_to_angle/2 with offset" do
    # With offset 90 the angle starts from the y axis.
    assert Util.vector_to_angle({0, 0}, offset: 90) == 0
    assert Util.vector_to_angle({1, 0}, offset: 90) == 270
    assert Util.vector_to_angle({0, 1}, offset: 90) == 0
    assert Util.vector_to_angle({-1, 0}, offset: 90) == 90
    assert Util.vector_to_angle({0, -1}, offset: 90) == 180
  end

  test "vector_to_angle/2 with offset and clockwise" do
    # With offset 90 the angle starts from the y axis.
    assert Util.vector_to_angle({0, 0}, offset: 90, clockwise: true) == 0
    assert Util.vector_to_angle({1, 0}, offset: 90, clockwise: true) == 90
    assert Util.vector_to_angle({0, 1}, offset: 90, clockwise: true) == 0
    assert Util.vector_to_angle({-1, 0}, offset: 90, clockwise: true) == 270
    assert Util.vector_to_angle({0, -1}, offset: 90, clockwise: true) == 180
  end

  test "vector_to_distance/1" do
    assert Util.vector_to_distance({0, 0}) == 0
    assert Util.vector_to_distance({1, 0}) == 1
    assert Util.vector_to_distance({0, 1}) == 1
    assert Util.vector_to_distance({3, 4}) == 5
  end

  test "to_indexed_map/1" do
    orig_list = ["a", "b", "c"]
    expected = %{0 => "a", 1 => "b", 2 => "c"}

    assert Util.to_indexed_map(orig_list) == expected
  end

  test "to_indexed_map/2 with transformer" do
    orig_list = [1, 2, 3]
    expected = %{0 => 2, 1 => 4, 2 => 6}

    assert Util.to_indexed_map(orig_list, &(&1 * 2)) == expected
  end

  test "to_indexed_map/2 with transformer, item is tuple" do
    orig_list = [{1, "ugh"}, {2, "um"}, {3, "oh"}]
    expected = %{0 => "ugh", 1 => "um", 2 => "oh"}

    assert Util.to_indexed_map(orig_list, &elem(&1, 1)) == expected
  end
end
