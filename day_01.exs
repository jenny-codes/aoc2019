defmodule SpaceShip do
  def calculate_fuel(mass) do
    result = trunc(mass / 3) - 2
    cond do
      result <= 0 -> 0
      result > 0 -> result + calculate_fuel(result)
    end
  end
end

File.stream!('input/day_01.txt')
|> Stream.map(&String.trim/1)
|> Stream.map(&Integer.parse/1)
|> Stream.map(fn {v, _k} -> v end)
|> Stream.map(&SpaceShip.calculate_fuel/1)
|> Enum.reduce(0, &+/2)
|> IO.puts

