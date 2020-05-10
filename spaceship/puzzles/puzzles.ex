defmodule Spaceship.Puzzles do
  def day05_2(program_str, input: input) do
    input_fn = fn opts ->
      [input_val | updated_input_args] = opts[:input_args]
      {input_val, Keyword.put(opts, :input_args, updated_input_args)}
    end

    output_fn = fn _output_val -> :return end

    program_str
    |> Spaceship.Component.IntcodeMachine.build_program()
    |> Spaceship.Component.IntcodeMachine.execute(
      input_fn: input_fn,
      input_args: [input],
      output_fn: output_fn
    )
  end

  def day07_2(phase_setting_sequence, program_str) do
    phase_setting_sequence
    |> Spaceship.AmplificationCircuit.init(0)
    |> Spaceship.AmplificationCircuit.run(program_str)
  end

  def day08_1(pixel_str, image_size) do
    pixel_str
    |> Spaceship.Component.SpaceImageFormat.from_pixel_str(image_size)
    |> Enum.map(&Spaceship.Util.count_items/1)
    |> Enum.min_by(& &1[0])
    |> (fn x -> x[1] * x[2] end).()
  end

  def day08_2(pixel_str, image_size) do
    pixel_str
    |> Spaceship.Component.SpaceImageFormat.from_pixel_str(image_size)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Spaceship.Component.SpaceImageFormat.parse_image_color()
    |> Spaceship.Component.SpaceImageFormat.print_image(image_size)
  end

  def day09(program_str, initial_input \\ nil) do
    input_fn = fn opts ->
      [input_val | updated_input_args] = opts[:input_args]
      {input_val, Keyword.put(opts, :input_args, updated_input_args)}
    end

    output_fn = fn output_val ->
      IO.inspect(output_val, label: "Output value")
      # :return
      :continue
    end

    program_str
    |> Spaceship.Component.IntcodeMachine.build_program()
    |> Spaceship.Component.IntcodeMachine.execute(
      input_fn: input_fn,
      input_args: [initial_input],
      output_fn: output_fn
    )
  end

  def day10_1(asteroid_map_str) do
    asteroid_map_str
    |> Spaceship.Component.MonitoringStation.from_input()
    |> Spaceship.Component.MonitoringStation.direction_map()
    # TODO: We can use `for` comprehension to transform a map's value
    |> Enum.map(fn {ast, dirs} -> {ast, MapSet.size(dirs)} end)
    |> Enum.max_by(fn {_ast, count} -> count end)
    |> IO.inspect()
  end

  def day10_2(ast_map_str, station, target) do
    ast_map_str
    |> Spaceship.Component.MonitoringStation.from_input()
    |> Spaceship.Component.MonitoringStation.direction_and_distance_map(station)
    |> Spaceship.Component.MonitoringStation.find_laser_target(target)
    |> IO.inspect()
  end
end
