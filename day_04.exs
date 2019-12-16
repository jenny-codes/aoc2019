defmodule SpaceShip do
  def is_valid_password?(num, status \\ 'pending')

  # finished iteration
  def is_valid_password?(num, status) when div(num, 10) == 0 do
    status == 'pass' || status == 'matching'
  end

  def is_valid_password?(num, status) do
    cur = rem(num, 10)
    num = div(num, 10)
    next = rem(num, 10)

    cond do
      cur < next ->
        false

      cur == next ->
        case status do
          'pass' -> is_valid_password?(num, 'pass')
          'pending' -> is_valid_password?(num, 'matching')
          'matching' -> is_valid_password?(num, 'exceeding')
          'exceeding' -> is_valid_password?(num, 'exceeding')
        end

      true ->
        case status do
          'matching' -> is_valid_password?(num, 'pass')
          'exceeding' -> is_valid_password?(num, 'pending')
          _ -> is_valid_password?(num, status)
        end
    end
  end
end

109_165..576_723
|> Enum.filter(&SpaceShip.is_valid_password?/1)
|> Enum.count()
|> IO.puts()
