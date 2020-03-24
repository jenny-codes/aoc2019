defmodule SpaceshipTest do
  use ExUnit.Case
  doctest Spaceship

  test "greets the world" do
    assert Spaceship.hello() == :world
  end
end
