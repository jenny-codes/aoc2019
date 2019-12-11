defmodule Spaceship do
  def get_input_to_map(input) do
    File.read!(input)
    |> String.split(",", trim: true)
    |> Stream.map(&Integer.parse/1)
    |> Stream.map(fn {v, _k} -> v end)
    |> Stream.with_index()
    |> Map.new(fn {x, i} -> {i, x} end)
  end

  def update_noun_and_verb(data, noun, verb) do
    data
    |> Map.put(1, noun)
    |> Map.put(2, verb)
  end

  def calculate(data, i \\ 0) do
    case data[i] do
      1 ->
        Spaceship.calculate(
          Map.put(data, data[i + 3], data[data[i + 1]] + data[data[i + 2]]),
          i + 4
        )

      2 ->
        Spaceship.calculate(
          Map.put(data, data[i + 3], data[data[i + 1]] * data[data[i + 2]]),
          i + 4
        )

      99 ->
        data[0]
    end
  end
end

for n <- 0..99, v <- 0..99 do
  'input/day_02.txt'
  |> Spaceship.get_input_to_map()
  |> Spaceship.update_noun_and_verb(n, v)
  |> Spaceship.calculate()
  |> (fn num -> if(num == 19_690_720, do: IO.puts(100 * n + v)) end).()
end
