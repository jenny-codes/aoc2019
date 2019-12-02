def calculate(noun, verb)
  File.open('input/day_02.txt').each do |line|
    data = line.split(',').tap do |d|
      d.map!(&:to_i)
      d[1] = noun
      d[2] = verb
    end

    i = 0
    while data[i] != 99
      if data[i] == 1
        data[data[i+3]] = data[data[i+1]] + data[data[i+2]]
      elsif data[i] == 2
        data[data[i+3]] = data[data[i+1]] * data[data[i+2]]
      else
        puts 'oops'
      end
      i += 4
    end

    return data[0]
  end
end

0.upto(99).each do |noun|
  0.upto(99).each do |verb|
    if calculate(noun, verb) == 19690720
      puts 100*noun + verb
      return
    end
  end
end
