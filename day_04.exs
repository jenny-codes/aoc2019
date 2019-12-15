defmodule SpaceShip do
  def possible_passwords_count(range) do
    range
    |> Enum.map(&is_valid_password?/1)
    |> Enum.count(&(&1 == true))
  end

  def is_valid_password?(num) do
    digits =
      num
      |> to_string()
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)

    # Part 1
    # Enum.sort(digits) == digits && has_same_adjacent_digits?(digits)

    # Part 2
    Enum.sort(digits) == digits && has_one_pair_same_digits?(digits)
  end

  def has_same_adjacent_digits?([_ | digits]) when digits == [], do: false
  def has_same_adjacent_digits?([n | digits]) when n == hd(digits), do: true
  def has_same_adjacent_digits?([_ | digits]), do: has_same_adjacent_digits?(digits)

  def has_one_pair_same_digits?(digits, count \\ 1)

  def has_one_pair_same_digits?(digits, count) when tl(digits) == [],
    do: count == 2

  def has_one_pair_same_digits?([n | tail], count) when n == hd(tail) do
    has_one_pair_same_digits?(tail, count + 1)
  end

  def has_one_pair_same_digits?([_ | digits], count) do
    case count do
      2 -> true
      _ -> has_one_pair_same_digits?(digits, 1)
    end
  end
end

SpaceShip.possible_passwords_count(109_165..576_723)
|> IO.puts()
