defmodule Spaceship.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    # Instead of using `{:ok, registry} = Spaceship.Registry.start_link([])`,
    # in test we use the syntax below to ensure the state is properly cleaned up
    # after each test.
    registry = start_supervised!(Spaceship.Registry)
    %{registry: registry}
  end

  test "successful spawning buckets returns ok", %{registry: registry} do
    assert :ok == Spaceship.Registry.create(registry, "a bucket")
  end

  test "lookup with inexistent name returns error", %{registry: registry} do
    assert :error == Spaceship.Registry.lookup(registry, "nonexistent bucket")
  end

  test "successful lookup returns desired bucket", %{registry: registry} do
    Spaceship.Registry.create(registry, "a bucket")
    assert {:ok, _bucket} = Spaceship.Registry.lookup(registry, "a bucket")
  end
end
