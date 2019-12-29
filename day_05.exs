# require IEx

defmodule IntCode do
  def get_input_to_map(input) do
    File.read!(input)
    |> String.split(",", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index()
    |> Map.new(fn {x, i} -> {i, x} end)
  end

  def calculate(data, i \\ 0) do
    case rem(data[i], 100) do
      1 ->
        {first_op, second_op} = calculate_ops(data, i)

        calculate(
          Map.put(data, data[i + 3], first_op + second_op),
          i + 4
        )

      2 ->
        {first_op, second_op} = calculate_ops(data, i)

        calculate(
          Map.put(data, data[i + 3], first_op * second_op),
          i + 4
        )

      3 ->
        calculate(
          Map.put(
            data,
            data[i + 1],
            IO.gets('input n:')
            |> String.trim()
            |> String.to_integer()
          ),
          i + 2
        )

      4 ->
        {value, _} = calculate_ops(data, i)
        IO.puts(value)

        calculate(
          data,
          i + 2
        )

      99 ->
        data[0]
    end
  end

  def calculate_ops(data, i) do
    case div(data[i], 100) do
      0 ->
        {data[data[i + 1]], data[data[i + 2]]}

      1 ->
        {data[i + 1], data[data[i + 2]]}

      10 ->
        {data[data[i + 1]], data[i + 2]}

      11 ->
        {data[i + 1], data[i + 2]}
    end
  end

  def value_with(data, value, mode) when mode == 0, do: data[value]
  def value_with(_, value, mode) when mode == 1, do: value
end

'input/day_05.txt'
|> IntCode.get_input_to_map()
|> IntCode.calculate()
