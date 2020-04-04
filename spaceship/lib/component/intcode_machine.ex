defmodule Spaceship.Component.IntcodeMachine do
  def build_program(input_str) do
    Spaceship.Util.str_sequence_into_index_map(input_str)
  end

  def execute(program, opts \\ []) do
    execute(program, opcode_for(program[0]), 0, opts)
  end

  @spec execute(map, number, number, keyword) :: any
  def execute(program, opcode, pos, opts) when opcode == 1 do
    next_pos = pos + 4
    {first_op, second_op} = params_for(program, pos)
    updated_program = Map.put(program, program[pos + 3], first_op + second_op)

    if opts[:is_debug],
      do: {updated_program, next_pos},
      else: execute(updated_program, opcode_for(updated_program[next_pos]), next_pos, opts)
  end

  def execute(program, opcode, pos, opts) when opcode == 2 do
    next_pos = pos + 4
    {first_op, second_op} = params_for(program, pos)
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
    {output_val, _} = params_for(program, pos)

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
    {should_jump, destination} = params_for(program, pos)

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
    {should_jump, destination} = params_for(program, pos)

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
    {first_op, second_op} = params_for(program, pos)

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
    {first_op, second_op} = params_for(program, pos)

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

  def execute(_program, opcode, _i, _opts) when opcode == 99 do
    :ok
  end

  def deconstruct(program) do
    Spaceship.Util.index_map_into_str_sequence(program)
  end

  defp params_for(program, pos) do
    case div(program[pos], 100) do
      0 ->
        {program[program[pos + 1]], program[program[pos + 2]]}

      1 ->
        {program[pos + 1], program[program[pos + 2]]}

      10 ->
        {program[program[pos + 1]], program[pos + 2]}

      11 ->
        {program[pos + 1], program[pos + 2]}
    end
  end

  defp opcode_for(num) do
    rem(num, 100)
  end
end
