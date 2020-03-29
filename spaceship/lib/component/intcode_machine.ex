defmodule Spaceship.Component.IntcodeMachine do
  def build_program(input_str) do
    input_str
    |> String.split(",", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index()
    |> Map.new(fn {x, i} -> {i, x} end)
  end

  def execute(data, i \\ 0, input_args \\ [])

  def execute(data, i, input_args) do
    case rem(data[i], 100) do
      1 ->
        {first_op, second_op} = calculate_ops(data, i)

        execute(
          Map.put(data, data[i + 3], first_op + second_op),
          i + 4,
          input_args
        )

      2 ->
        {first_op, second_op} = calculate_ops(data, i)

        execute(
          Map.put(data, data[i + 3], first_op * second_op),
          i + 4,
          input_args
        )

      3 ->
        [input | remaining_input_args] = input_args

        execute(
          Map.put(data, data[i + 1], input),
          i + 2,
          remaining_input_args
        )

      4 ->
        {value, _} = calculate_ops(data, i)
        value

      # behavior for day_05
      # IO.puts(value)
      # execute(data, i + 2)

      5 ->
        {first_param, second_param} = calculate_ops(data, i)

        case first_param do
          0 ->
            execute(data, i + 3, input_args)

          _ ->
            execute(data, second_param, input_args)
        end

      6 ->
        {first_param, second_param} = calculate_ops(data, i)

        case first_param do
          0 ->
            execute(data, second_param, input_args)

          _ ->
            execute(data, i + 3, input_args)
        end

      7 ->
        {first_param, second_param} = calculate_ops(data, i)

        cond do
          first_param < second_param ->
            execute(
              Map.put(data, data[i + 3], 1),
              i + 4,
              input_args
            )

          true ->
            execute(
              Map.put(data, data[i + 3], 0),
              i + 4,
              input_args
            )
        end

      8 ->
        {first_param, second_param} = calculate_ops(data, i)

        cond do
          first_param == second_param ->
            execute(
              Map.put(data, data[i + 3], 1),
              i + 4,
              input_args
            )

          true ->
            execute(
              Map.put(data, data[i + 3], 0),
              i + 4,
              input_args
            )
        end

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
end
