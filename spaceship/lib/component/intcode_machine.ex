defmodule Spaceship.Component.IntcodeMachine do
  def build_program(input_str) do
    Spaceship.Util.str_sequence_into_index_map(input_str)
  end

  @spec execute(map, keyword) :: any
  def execute(program, opts \\ []) do
    execute(program, opcode_for(program[0]), 0, Keyword.put_new(opts, :relative_base, 0))
  end

  @spec execute(map, number, number, keyword) :: any
  def execute(program, opcode, pos, opts) when opcode == 1 do
    next_pos = pos + 4
    [first_op_pos, second_op_pos, output_pos] = params_for(program, pos, opts[:relative_base], 3)

    updated_program =
      Map.put(
        program,
        output_pos,
        value_with_fallback(program, first_op_pos) + value_with_fallback(program, second_op_pos)
      )

    if opts[:is_debug],
      do: {updated_program, next_pos},
      else:
        execute(
          updated_program,
          updated_program |> value_with_fallback(next_pos) |> opcode_for(),
          next_pos,
          opts
        )
  end

  def execute(program, opcode, pos, opts) when opcode == 2 do
    next_pos = pos + 4
    [first_op_pos, second_op_pos, output_pos] = params_for(program, pos, opts[:relative_base], 3)

    updated_program =
      Map.put(
        program,
        output_pos,
        value_with_fallback(program, first_op_pos) * value_with_fallback(program, second_op_pos)
      )

    if opts[:is_debug],
      do: {updated_program, next_pos},
      else:
        execute(
          updated_program,
          updated_program |> value_with_fallback(next_pos) |> opcode_for(),
          next_pos,
          opts
        )
  end

  def execute(program, opcode, pos, opts) when opcode == 3 do
    next_pos = pos + 2
    {input_val, updated_opts} = opts[:input_fn].(opts)
    [output_pos] = params_for(program, pos, opts[:relative_base], 1)
    updated_program = Map.put(program, output_pos, input_val)

    if opts[:is_debug],
      do: {updated_program, next_pos},
      else:
        execute(
          updated_program,
          updated_program |> value_with_fallback(next_pos) |> opcode_for(),
          next_pos,
          updated_opts
        )
  end

  def execute(program, opcode, pos, opts) when opcode == 4 do
    output_val =
      params_for(program, pos, opts[:relative_base], 1)
      |> (fn [output_val_pos] -> value_with_fallback(program, output_val_pos) end).()

    case opts[:output_fn].(output_val) do
      :return ->
        output_val

      :continue ->
        next_pos = pos + 2

        execute(
          program,
          program |> value_with_fallback(next_pos) |> opcode_for(),
          next_pos,
          opts
        )

      _ ->
        raise "output_fn should return either :return or :continue"
    end
  end

  def execute(program, opcode, pos, opts) when opcode == 5 do
    [should_jump, destination] =
      params_for(program, pos, opts[:relative_base], 2)
      |> Enum.map(&value_with_fallback(program, &1))

    next_pos =
      if should_jump == 0 do
        pos + 3
      else
        destination
      end

    if opts[:is_debug],
      do: {program, next_pos},
      else:
        execute(
          program,
          program |> value_with_fallback(next_pos) |> opcode_for(),
          next_pos,
          opts
        )
  end

  def execute(program, opcode, pos, opts) when opcode == 6 do
    [should_jump, destination] =
      params_for(program, pos, opts[:relative_base], 2)
      |> Enum.map(&value_with_fallback(program, &1))

    next_pos =
      if should_jump == 0 do
        destination
      else
        pos + 3
      end

    if opts[:is_debug],
      do: {program, next_pos},
      else:
        execute(
          program,
          program |> value_with_fallback(next_pos) |> opcode_for(),
          next_pos,
          opts
        )
  end

  def execute(program, opcode, pos, opts) when opcode == 7 do
    next_pos = pos + 4
    [first_op_pos, second_op_pos, output_pos] = params_for(program, pos, opts[:relative_base], 3)

    updated_program =
      if value_with_fallback(program, first_op_pos) < value_with_fallback(program, second_op_pos) do
        Map.put(program, output_pos, 1)
      else
        Map.put(program, output_pos, 0)
      end

    if opts[:is_debug],
      do: {updated_program, next_pos},
      else:
        execute(
          updated_program,
          updated_program |> value_with_fallback(next_pos) |> opcode_for(),
          next_pos,
          opts
        )
  end

  def execute(program, opcode, pos, opts) when opcode == 8 do
    next_pos = pos + 4
    [first_op_pos, second_op_pos, output_pos] = params_for(program, pos, opts[:relative_base], 3)

    updated_program =
      if value_with_fallback(program, first_op_pos) == value_with_fallback(program, second_op_pos) do
        Map.put(program, output_pos, 1)
      else
        Map.put(program, output_pos, 0)
      end

    if opts[:is_debug],
      do: {updated_program, next_pos},
      else:
        execute(
          updated_program,
          updated_program |> value_with_fallback(next_pos) |> opcode_for(),
          next_pos,
          opts
        )
  end

  def execute(program, opcode, pos, opts) when opcode == 9 do
    next_pos = pos + 2

    updated_ops =
      params_for(program, pos, opts[:relative_base], 1)
      |> (fn [pos] -> value_with_fallback(program, pos) end).()
      |> (fn adjustment ->
            Keyword.put(opts, :relative_base, opts[:relative_base] + adjustment)
          end).()

    if opts[:is_debug],
      do: {program, next_pos, updated_ops},
      else:
        execute(
          program,
          program |> value_with_fallback(next_pos) |> opcode_for(),
          next_pos,
          updated_ops
        )
  end

  def execute(_program, opcode, _i, _opts) when opcode == 99 do
    :ok
  end

  def deconstruct(program) do
    Spaceship.Util.index_map_into_str_sequence(program)
  end

  defp value_with_fallback(program, key) do
    Map.get(program, key, 0)
  end

  defp params_for(program, pos, relative_base, arity) do
    program
    |> value_with_fallback(pos)
    |> div(100)
    |> to_mode_list(arity)
    |> Enum.map(fn {mode_pos, mode} ->
      fetch_param_location(
        pos + mode_pos,
        value_with_fallback(program, pos + mode_pos),
        mode,
        relative_base
      )
    end)
  end

  def to_mode_list(num, arity, acc \\ [])

  def to_mode_list(_num, arity, acc) when arity == 0, do: acc

  def to_mode_list(num, arity, acc) do
    base = round(:math.pow(10, arity - 1))
    to_mode_list(rem(num, base), arity - 1, [{arity, div(num, base)} | acc])
  end

  # 0 => position mode
  # 1 => immdeiate mode
  # 2 => relative mode
  defp fetch_param_location(pos, value, mode, relative_base) do
    case mode do
      0 -> value
      1 -> pos
      2 -> value + relative_base
    end
  end

  defp opcode_for(num) do
    rem(num, 100)
  end
end
