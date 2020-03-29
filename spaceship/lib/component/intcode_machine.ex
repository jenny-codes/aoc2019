defmodule Spaceship.Component.IntcodeMachine do
  def build_program(input_str) do
    input_str
    |> String.split(",", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index()
    |> Map.new(fn {x, i} -> {i, x} end)
  end

  def execute(program, ops \\ %{}) do
    execute(program, opcode_for(program[0]), 0, ops)
  end

  @spec execute(nil | keyword | map, any, number, any) :: any
  def execute(program, opcode, i, ops) when opcode == 1 do
    next_pos = i + 4
    {first_op, second_op} = calculate_ops(program, i)
    updated_program = Map.put(program, program[i + 3], first_op + second_op)

    if ops[:is_debug],
      do: {updated_program, next_pos},
      else: execute(updated_program, opcode_for(updated_program[next_pos]), next_pos, ops)
  end

  def execute(program, opcode, i, ops) when opcode == 2 do
    next_pos = i + 4
    {first_op, second_op} = calculate_ops(program, i)
    updated_program = Map.put(program, program[i + 3], first_op * second_op)

    if ops[:is_debug],
      do: {updated_program, next_pos},
      else: execute(updated_program, opcode_for(updated_program[next_pos]), next_pos, ops)
  end

  def execute(program, opcode, i, ops) when opcode == 3 do
    next_pos = i + 2
    [input | remaining_input_args] = ops[:input_args]
    updated_ops = Map.put(ops, :input_args, remaining_input_args)
    updated_program = Map.put(program, program[i + 1], input)

    if ops[:is_debug],
      do: {updated_program, next_pos},
      else:
        execute(
          updated_program,
          opcode_for(updated_program[next_pos]),
          next_pos,
          updated_ops
        )
  end

  def execute(program, opcode, i, _ops) when opcode == 4 do
    {value, _} = calculate_ops(program, i)
    value
    # next_pos = i + 2
    # next_opcode = opcode_for(program[next_pos])
    # execute(program, next_pos, next_opcode, input_args)
  end

  def execute(program, opcode, i, ops) when opcode == 5 do
    {should_jump, destination} = calculate_ops(program, i)

    next_pos =
      if should_jump == 0 do
        i + 3
      else
        destination
      end

    if ops[:is_debug],
      do: {program, next_pos},
      else: execute(program, opcode_for(program[next_pos]), next_pos, ops)
  end

  def execute(program, opcode, i, ops) when opcode == 6 do
    {should_jump, destination} = calculate_ops(program, i)

    next_pos =
      if should_jump == 0 do
        destination
      else
        i + 3
      end

    if ops[:is_debug],
      do: {program, next_pos},
      else: execute(program, opcode_for(program[next_pos]), next_pos, ops)
  end

  def execute(program, opcode, i, ops) when opcode == 7 do
    next_pos = i + 4
    {first_op, second_op} = calculate_ops(program, i)

    updated_program =
      if first_op < second_op do
        Map.put(program, program[i + 3], 1)
      else
        Map.put(program, program[i + 3], 0)
      end

    if ops[:is_debug],
      do: {updated_program, next_pos},
      else: execute(updated_program, opcode_for(updated_program[next_pos]), next_pos, ops)
  end

  def execute(program, opcode, i, ops) when opcode == 8 do
    next_pos = i + 4
    {first_op, second_op} = calculate_ops(program, i)

    updated_program =
      if first_op == second_op do
        Map.put(program, program[i + 3], 1)
      else
        Map.put(program, program[i + 3], 0)
      end

    if ops[:is_debug],
      do: {updated_program, next_pos},
      else: execute(updated_program, opcode_for(updated_program[next_pos]), next_pos, ops)
  end

  def execute(program, opcode, _i, _ops) when opcode == 99 do
    program[0]
  end

  def deconstruct(program) do
    program
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(&program[&1])
    |> Enum.join(",")
  end

  defp calculate_ops(program, i) do
    case div(program[i], 100) do
      0 ->
        {program[program[i + 1]], program[program[i + 2]]}

      1 ->
        {program[i + 1], program[program[i + 2]]}

      10 ->
        {program[program[i + 1]], program[i + 2]}

      11 ->
        {program[i + 1], program[i + 2]}
    end
  end

  defp opcode_for(num) do
    rem(num, 100)
  end
end
