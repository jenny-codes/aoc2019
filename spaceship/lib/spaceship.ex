defmodule Spaceship do
  @moduledoc """
  Documentation for Spaceship.
  """
  use Application

  @impl true
  def start(_type, _args) do
    # Note: we don's use the supervisor name below directly,
    # but it can be usefule when debugging or introspecting
    # the system.
    Spaceship.Supervisor.start_link(name: Spaceship.Supervisor)
  end
end
