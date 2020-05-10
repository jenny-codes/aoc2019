defmodule Spaceship.Component.MonitoringStationTest do
  use ExUnit.Case, async: true

  alias Spaceship.Component.MonitoringStation

  describe "direction/2 returns the direction in degree from 1st to 2nd param" do
    test " works" do
      assert MonitoringStation.direction({3, 2}, {2, 3}) == 225
    end

    test "with 1st param == 2nd param returns 0" do
      assert MonitoringStation.direction({3, 3}, {3, 3}) == 0
    end

    test "with same directions vector should be the same" do
      vector1 = MonitoringStation.direction({0, 0}, {1, 1})
      vector2 = MonitoringStation.direction({0, 0}, {3, 3})

      vector3 = MonitoringStation.direction({0, 0}, {2, -1})
      vector4 = MonitoringStation.direction({0, 0}, {4, -2})

      vector5 = MonitoringStation.direction({2, 1}, {0, 0})
      vector6 = MonitoringStation.direction({4, 2}, {0, 0})

      assert vector1 == vector2
      assert vector3 == vector4
      assert vector5 == vector6
    end

    test "with same direction - straight angle" do
      vector1 = MonitoringStation.direction({0, 0}, {0, 1})
      vector2 = MonitoringStation.direction({0, 0}, {0, 3})

      vector3 = MonitoringStation.direction({0, 0}, {0, -1})
      vector4 = MonitoringStation.direction({0, 0}, {0, -3})

      assert vector1 == vector2
      assert vector3 == vector4
    end
  end

  describe "from_input/1" do
    test "draws a mapset of the asteroids" do
      input = ".#.\n#.#\n"

      assert MonitoringStation.from_input(input) == MapSet.new([{0, 1}, {1, 0}, {2, 1}])
    end

    test "returns empty mapset with empty input" do
      assert MonitoringStation.from_input("") == %MapSet{}
    end

    test "returns empty mapset with no asteroids" do
      assert MonitoringStation.from_input("...") == %MapSet{}
      assert MonitoringStation.from_input("...\n...") == %MapSet{}
    end

    test "returns one-item array with one-asteroid input" do
      assert MonitoringStation.from_input(".#.") == MapSet.new([{1, 0}])
    end
  end

  describe "direction_map/1" do
    test "draws a map of asteroids with each a list(mapset) of directions it has with others" do
      asteroids = MapSet.new([{1, 1}, {2, 3}])

      transform = fn vector ->
        Spaceship.Util.vector_to_angle(vector, clockwise: true, offset: 90)
      end

      assert MonitoringStation.direction_map(asteroids) == %{
               {1, 1} => MapSet.new([transform.({1, -2})]),
               {2, 3} => MapSet.new([transform.({-1, 2})])
             }
    end

    test "has only one entry if two asteroids share the same directions" do
      # The three androids are in the same line.
      asteroids = MapSet.new([{0, 0}, {1, 1}, {2, 2}])

      assert MonitoringStation.direction_map(asteroids) == %{
               {0, 0} => MapSet.new([135.0]),
               {1, 1} => MapSet.new([135.0, 315.0]),
               {2, 2} => MapSet.new([315.0])
             }
    end

    test "has only one entry if two asteroids share the same directions: vetical" do
      # The three androids are in the same line.
      asteroids = MapSet.new([{0, 0}, {0, 1}, {0, 2}])

      assert MonitoringStation.direction_map(asteroids) == %{
               {0, 0} => MapSet.new([180.0]),
               {0, 1} => MapSet.new([0.0, 180.0]),
               {0, 2} => MapSet.new([0.0])
             }
    end
  end

  describe "direction_and_distance_map/2" do
    test "with same angle" do
      ast1 = {0, 0}
      ast2 = {1, 1}
      ast3 = {2, 2}
      ast_list = [ast1, ast2, ast3]

      expected_map_for_ast1 = %{0 => %{0 => ast2, 1 => ast3}}
      expected_map_for_ast2 = %{0 => %{0 => ast3}, 1 => %{0 => ast1}}
      expected_map_for_ast3 = %{0 => %{0 => ast2, 1 => ast1}}

      map_for_ast1 = MonitoringStation.direction_and_distance_map(ast_list, ast1)
      map_for_ast2 = MonitoringStation.direction_and_distance_map(ast_list, ast2)
      map_for_ast3 = MonitoringStation.direction_and_distance_map(ast_list, ast3)

      assert expected_map_for_ast1 == map_for_ast1
      assert expected_map_for_ast2 == map_for_ast2
      assert expected_map_for_ast3 == map_for_ast3
    end

    test "with different angles" do
      pivot = {0, 0}
      angle90 = {1, 0}
      angle180 = {0, 1}

      expected_map = %{0 => %{0 => angle90}, 1 => %{0 => angle180}}
      result_map = MonitoringStation.direction_and_distance_map([pivot, angle90, angle180], pivot)

      assert expected_map == result_map
    end
  end

  describe "find_laser_target/2" do
    test "with a one-row map" do
      ast_map = %{0 => %{0 => {1, 1}, 1 => {2, 2}}}

      assert MonitoringStation.find_laser_target(ast_map, 1) == {1, 1}
      assert MonitoringStation.find_laser_target(ast_map, 2) == {2, 2}
    end

    test "with a one-column map" do
      ast_map = %{0 => %{0 => {1, 1}}, 1 => %{0 => {2, 2}}}

      assert MonitoringStation.find_laser_target(ast_map, 1) == {1, 1}
      assert MonitoringStation.find_laser_target(ast_map, 2) == {2, 2}
    end

    test "with map of different column lengths" do
      ast_map = %{0 => %{0 => {1, 1}}, 1 => %{0 => {2, 2}, 1 => {4, 4}}, 2 => %{0 => {3, 3}}}

      assert MonitoringStation.find_laser_target(ast_map, 1) == {1, 1}
      assert MonitoringStation.find_laser_target(ast_map, 2) == {2, 2}
      assert MonitoringStation.find_laser_target(ast_map, 3) == {3, 3}
      assert MonitoringStation.find_laser_target(ast_map, 4) == {4, 4}
    end
  end
end
