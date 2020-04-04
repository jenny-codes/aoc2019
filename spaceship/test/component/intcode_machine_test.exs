defmodule Spaceship.Component.IntcodeMachineTest do
  use ExUnit.Case, async: true

  test "#build_program returns an instruction map with index as key" do
    program_str = "1,2,3"
    expected_program = %{0 => 1, 1 => 2, 2 => 3}

    assert Spaceship.Component.IntcodeMachine.build_program(program_str) == expected_program
  end

  test "#deconstruct returns a string of instructions" do
    program = %{0 => 1, 1 => 2, 2 => 3}
    expected_progrma_str = "1,2,3"

    assert Spaceship.Component.IntcodeMachine.deconstruct(program) == expected_progrma_str
  end

  test 'opcode 1 adds the 1st and 2nd param and update to the location 3rd param points to' do
    {program, next_pos} = execute_intcode_machine("1101,100,200,3")

    assert next_pos == 4
    assert program == "1101,100,200,300"
  end

  test 'opcode 2 times the 1st and 2nd param and update to the location 3rd param points to' do
    {program, next_pos} = execute_intcode_machine("1102,100,200,3")

    assert next_pos == 4
    assert program == "1102,100,200,20000"
  end

  test 'opcode 3 gets input from :input_fn and updates to the location 1st param points to' do
    input_fn = fn opts ->
      [input_val | updated_input_args] = opts[:input_args]
      {input_val, Keyword.put(opts, :input_args, updated_input_args)}
    end

    {program, next_pos} =
      execute_intcode_machine("1103,0", input_fn: input_fn, input_args: [10000])

    assert next_pos == 2
    assert program == "10000,0"
  end

  test 'opcode 4 gets instruction from :output_fn with the value of 1st param' do
    output_fn = fn(_val) -> :return end

    ret_value =
      "1104,10000"
      |> Spaceship.Component.IntcodeMachine.build_program()
      |> Spaceship.Component.IntcodeMachine.execute(output_fn: output_fn)

    assert ret_value == 10000
  end

  test 'opcode 5 moves forward if 1st param is 0' do
    {program, next_pos} = execute_intcode_machine("1105,0,100")

    assert program == "1105,0,100"
    assert next_pos == 3
  end

  test 'opcode 5 jumps to the location of 2nd param if 1st param is not 0' do
    {program, next_pos} = execute_intcode_machine("1105,1,100")

    assert program == "1105,1,100"
    assert next_pos == 100
  end

  test 'opcode 6 moves forward if 1st param is not 0' do
    {program, next_pos} = execute_intcode_machine("1106,1,100")

    assert program == "1106,1,100"
    assert next_pos == 3
  end

  test 'opcode 6 jumps to the location of 2nd param if 1st param is 0' do
    {program, next_pos} = execute_intcode_machine("1106,0,100")

    assert program == "1106,0,100"
    assert next_pos == 100
  end

  test 'opcode 7 stores 1 in the position given by 3rd param if 1st param < 2nd param' do
    {program, next_pos} = execute_intcode_machine("1107,99,100,0")

    assert program == "1,99,100,0"
    assert next_pos == 4
  end

  test 'opcode 7 stores 0 in the position given by 3rd param if 1st param >= 2nd param' do
    {program, next_pos} = execute_intcode_machine("1107,101,100,0")

    assert program == "0,101,100,0"
    assert next_pos == 4
  end

  test 'opcode 8 stores 0 in the position given by 3rd param if 1st param == 2nd param' do
    {program, next_pos} = execute_intcode_machine("1108,100,100,0")

    assert program == "1,100,100,0"
    assert next_pos == 4
  end

  test 'opcode 8 stores 0 in the position given by 3rd param if 1st param != 2nd param' do
    {program, next_pos} = execute_intcode_machine("1108,99,100,0")

    assert program == "0,99,100,0"
    assert next_pos == 4
  end

  test 'opcode 9 updates :relative_base with 1st param' do
    {_program, next_pos, opts} =
      "109,333"
      |> Spaceship.Component.IntcodeMachine.build_program()
      |> Spaceship.Component.IntcodeMachine.execute(is_debug: true)

    assert next_pos == 2
    assert opts[:relative_base] == 333
  end

  test 'opcode 99 returns :ok' do
    ret_value =
      "99"
      |> Spaceship.Component.IntcodeMachine.build_program()
      |> Spaceship.Component.IntcodeMachine.execute()

    assert ret_value == :ok
  end

  describe "relative mode returns pointed value with position adjusted with :relative_base" do
    test "no adjustments with default relative base" do
      {program, next_pos} = execute_intcode_machine("2201,3,3,3")

      assert next_pos == 4
      assert program == "2201,3,3,6"
    end

    test "positive adjustment with positive :relative_base" do
      {program, next_pos} = execute_intcode_machine("2201,2,2,3", relative_base: 1)

      assert next_pos == 4
      assert program == "2201,2,2,6"
    end

    test "positive adjustment with negative :relative_base" do
      {program, next_pos} = execute_intcode_machine("2201,4,4,3", relative_base: -1)

      assert next_pos == 4
      assert program == "2201,4,4,6"
    end

    test "for opcode with one param" do
      output_fn = fn _val -> :return end

      ret_value =
        "204,1,3"
        |> Spaceship.Component.IntcodeMachine.build_program()
        |> Spaceship.Component.IntcodeMachine.execute(output_fn: output_fn, relative_base: 1)

      assert ret_value == 3
    end

    test "with :relative_base updated from opcode 9" do
      output_fn = fn _val -> :return end

      ret_value =
        "209,1,204,1"
        |> Spaceship.Component.IntcodeMachine.build_program()
        |> Spaceship.Component.IntcodeMachine.execute(output_fn: output_fn)

      assert ret_value == 204
    end
  end

  test "mixed modes work" do
    {program, next_pos} = execute_intcode_machine("1201,300,4,3", relative_base: -1)

    assert next_pos == 4
    assert program == "1201,300,4,303"
  end

  def execute_intcode_machine(program_str, opts \\ []) do
    program_str
    |> Spaceship.Component.IntcodeMachine.build_program()
    |> Spaceship.Component.IntcodeMachine.execute([{:is_debug, true} | opts])
    |> (fn {pg, pos} ->
          {Spaceship.Component.IntcodeMachine.deconstruct(pg), pos}
        end).()
  end
end
