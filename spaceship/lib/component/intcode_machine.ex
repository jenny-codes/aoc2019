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
    {first_op, second_op} = params_for(program, pos, opts[:relative_base])
    updated_program = Map.put(program, program[pos + 3], first_op + second_op)

    if opts[:is_debug],
      do: {updated_program, next_pos},
      else: execute(updated_program, opcode_for(updated_program[next_pos]), next_pos, opts)
  end

  def execute(program, opcode, pos, opts) when opcode == 2 do
    next_pos = pos + 4
    {first_op, second_op} = params_for(program, pos, opts[:relative_base])
    updated_program = Map.put(program, program[pos + 3], first_op * second_op)

    if opts[:is_debug],
      do: {updated_program, next_pos},
      else: execute(updated_program, opcode_for(updated_program[next_pos]), next_pos, opts)
  end

  def execute(program, opcode, pos, opts) when opcode == 3 do
    next_pos = pos + 2
    {input_val, updated_opts} = opts[:input_fn].(opts)
    updated_program = Map.put(program, program[pos + 1], input_val)

    if opts[:is_debug],
      do: {updated_program, next_pos},
      else:
        execute(
          updated_program,
          opcode_for(updated_program[next_pos]),
          next_pos,
          updated_opts
        )
  end

  def execute(program, opcode, pos, opts) when opcode == 4 do
    output_val = param_for(program, pos, opts[:relative_base])

    case opts[:output_fn].(output_val) do
      :return ->
        output_val

      :continue ->
        next_pos = pos + 2
        execute(program, opcode_for(program[next_pos]), next_pos, opts)

      _ ->
        raise "output_fn should return either :return or :continue"
    end
  end

  def execute(program, opcode, pos, opts) when opcode == 5 do
    {should_jump, destination} = params_for(program, pos, opts[:relative_base])

    next_pos =
      if should_jump == 0 do
        pos + 3
      else
        destination
      end

    if opts[:is_debug],
      do: {program, next_pos},
      else: execute(program, opcode_for(program[next_pos]), next_pos, opts)
  end

  def execute(program, opcode, pos, opts) when opcode == 6 do
    {should_jump, destination} = params_for(program, pos, opts[:relative_base])

    next_pos =
      if should_jump == 0 do
        destination
      else
        pos + 3
      end

    if opts[:is_debug],
      do: {program, next_pos},
      else: execute(program, opcode_for(program[next_pos]), next_pos, opts)
  end

  def execute(program, opcode, pos, opts) when opcode == 7 do
    next_pos = pos + 4
    {first_op, second_op} = params_for(program, pos, opts[:relative_base])

    updated_program =
      if first_op < second_op do
        Map.put(program, program[pos + 3], 1)
      else
        Map.put(program, program[pos + 3], 0)
      end

    if opts[:is_debug],
      do: {updated_program, next_pos},
      else: execute(updated_program, opcode_for(updated_program[next_pos]), next_pos, opts)
  end

  def execute(program, opcode, pos, opts) when opcode == 8 do
    next_pos = pos + 4
    {first_op, second_op} = params_for(program, pos, opts[:relative_base])

    updated_program =
      if first_op == second_op do
        Map.put(program, program[pos + 3], 1)
      else
        Map.put(program, program[pos + 3], 0)
      end

    if opts[:is_debug],
      do: {updated_program, next_pos},
      else: execute(updated_program, opcode_for(updated_program[next_pos]), next_pos, opts)
  end

  def execute(program, opcode, pos, opts) when opcode == 9 do
    next_pos = pos + 2
    adjustment = param_for(program, pos, opts[:relative_base])
    updated_ops = Keyword.put(opts, :relative_base, opts[:relative_base] + adjustment)

    if opts[:is_debug],
      do: {program, next_pos, updated_ops},
      else: execute(program, opcode_for(program[next_pos]), next_pos, updated_ops)
  end

  def execute(_program, opcode, _i, _opts) when opcode == 99 do
    :ok
  end

  def deconstruct(program) do
    Spaceship.Util.index_map_into_str_sequence(program)
  end

  defp param_for(program, pos, relative_base) do
    fetch_param(program, program[pos + 1], div(program[pos], 100), relative_base)
  end

  defp params_for(program, pos, relative_base) do

    program[pos]
    |> div(100)
    |> (fn x -> {div(x, 10), rem(x, 10)} end).()
    |> (fn {first_mode, second_mode} ->
          {
            fetch_param(program, program[pos + 1], first_mode, relative_base),
            fetch_param(program, program[pos + 2], second_mode, relative_base)
          }
        end).()
  end

  # 0 => position mode
  # 1 => immdeiate mode
  # 2 => relative mode
  defp fetch_param(program, value, mode, relative_base) do
    case mode do
      0 -> program[value]
      1 -> value
      2 -> program[value + relative_base]
    end
  end

  defp opcode_for(num) do
    rem(num, 100)
  end
end
