def calculate_fuel(mass)
  result = mass / 3 - 2
  return 0 if result <= 0

  result + calculate_fuel(result)
end

memo = 0
File.open('input/day_01.txt').each do | mass|
  memo += calculate_fuel(mass.to_i)
end

puts memo
