defmodule Spaceship.Component.MonitoringStationTest do
  use ExUnit.Case, async: true

  alias Spaceship.Component.MonitoringStation

  describe "calculate_vector_direction/2 returns the vector direction from 1st param to 2nd param" do
    test " works" do
      assert MonitoringStation.calculate_vector_direction({3, 2}, {2, 3}) == {-1, 1}
    end

    test "with 1st param == 2nd param returns {0, 0}" do
      assert MonitoringStation.calculate_vector_direction({3, 3}, {3, 3}) == {0, 0}
    end

    test "with same directions vector should be the same" do
      vector1 = MonitoringStation.calculate_vector_direction({0, 0}, {1, 1})
      vector2 = MonitoringStation.calculate_vector_direction({0, 0}, {3, 3})

      vector3 = MonitoringStation.calculate_vector_direction({0, 0}, {2, -1})
      vector4 = MonitoringStation.calculate_vector_direction({0, 0}, {4, -2})

      vector5 = MonitoringStation.calculate_vector_direction({2, 1}, {0, 0})
      vector6 = MonitoringStation.calculate_vector_direction({4, 2}, {0, 0})

      assert vector1 == vector2
      assert vector3 == vector4
      assert vector5 == vector6
    end

    test "with same direction - straight angle" do
      vector1 = MonitoringStation.calculate_vector_direction({0, 0}, {0, 1})
      vector2 = MonitoringStation.calculate_vector_direction({0, 0}, {0, 3})

      vector3 = MonitoringStation.calculate_vector_direction({0, 0}, {0, -1})
      vector4 = MonitoringStation.calculate_vector_direction({0, 0}, {0, -3})

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

  describe "draw_directions/1" do
    test "draws a map of asteroids with each a list(mapset) of directions it has with others" do
      asteroids = MapSet.new([{1, 1}, {2, 3}])

      assert MonitoringStation.draw_directions(asteroids) == %{
               {1, 1} => MapSet.new([{1, 2}]),
               {2, 3} => MapSet.new([{-1, -2}])
             }
    end

    test "has only one entry if two asteroids share the same directions" do
      # The three androids are in the same line.
      asteroids = MapSet.new([{0, 0}, {1, 1}, {2, 2}])

      assert MonitoringStation.draw_directions(asteroids) == %{
               {0, 0} => MapSet.new([{1, 1}]),
               {1, 1} => MapSet.new([{1, 1}, {-1, -1}]),
               {2, 2} => MapSet.new([{-1, -1}]),
             }
    end

    test "has only one entry if two asteroids share the same directions: vetical" do
      # The three androids are in the same line.
      asteroids = MapSet.new([{0, 0}, {0, 1}, {0, 2}])

      assert MonitoringStation.draw_directions(asteroids) == %{
               {0, 0} => MapSet.new([{0, 1}]),
               {0, 1} => MapSet.new([{0, 1}, {0, -1}]),
               {0, 2} => MapSet.new([{0, -1}]),
             }
    end
  end
end
