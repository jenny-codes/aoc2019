defmodule Spaceship.Component.SpaceImageFormatTest do
  use ExUnit.Case, async: true

  describe "parse_color/1 given a list of pixel's layers returns the color of pixel" do
    test "with one layer" do
      assert Spaceship.Component.SpaceImageFormat.parse_color([0]) == 0
      assert Spaceship.Component.SpaceImageFormat.parse_color([1]) == 1
      assert Spaceship.Component.SpaceImageFormat.parse_color([2]) == 2
    end

    test "with two layers" do
      assert Spaceship.Component.SpaceImageFormat.parse_color([0, 1]) == 0
      assert Spaceship.Component.SpaceImageFormat.parse_color([1, 2]) == 1
      assert Spaceship.Component.SpaceImageFormat.parse_color([0, 2]) == 0
      assert Spaceship.Component.SpaceImageFormat.parse_color([1, 0]) == 1
      assert Spaceship.Component.SpaceImageFormat.parse_color([2, 1]) == 1
      assert Spaceship.Component.SpaceImageFormat.parse_color([2, 0]) == 0
    end
  end
end
