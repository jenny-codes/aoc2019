defmodule Spaceship.Repo do
  use Ecto.Repo,
    otp_app: :spaceship,
    adapter: Ecto.Adapters.Postgres
end
