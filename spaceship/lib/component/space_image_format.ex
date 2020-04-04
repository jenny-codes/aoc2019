defmodule Spaceship.Component.SpaceImageFormat do
  @black 0
  @white 1
  @transparent 2

  def from_pixel_str(pixel_str, {width, height}) do
    pixel_str
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(width * height)
  end

  def print_image(image, {width, _height}) do
    transform = %{@black => " ", @white => "O", @transparent => " "}

    image
    |> Enum.map(&transform[&1])
    |> Enum.chunk_every(width)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def parse_image_color(image_with_layers) do
    image_with_layers
    |> Enum.map(&parse_color/1)
  end

  def parse_color([layer | _tail]) when layer in [@black, @white] do
    layer
  end

  def parse_color([layer | tail]) when layer == @transparent do
    parse_color(tail)
  end

  def parse_color([]), do: @transparent
end
