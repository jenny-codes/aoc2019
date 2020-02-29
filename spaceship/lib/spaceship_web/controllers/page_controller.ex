defmodule SpaceshipWeb.PageController do
  use SpaceshipWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
