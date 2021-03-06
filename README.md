# Advent of Code 2019 with Elixir!
- Decided to learn Elixir while doing the AOC challenge. A new language and fun puzzles at the same time!
- AOC website: https://adventofcode.com/2019

# Elixir Learning Notes
- Elixir website: https://elixir-lang.org
- This document is organized around the puzzles for each day.

## Day 01 - Getting Started
### Docs
- https://elixir-lang.org/getting-started/basic-types.html
- https://elixir-lang.org/getting-started/modules-and-functions.html
- https://elixir-lang.org/getting-started/io-and-the-file-system.html
- https://joyofelixir.com/11-files/
- https://elixir-lang.org/getting-started/enumerables-and-streams.html

### Overview
- Elixir projects are usually organized into three directories:
  - ebin: contains the compiled bytecode
  - lib: contains elixir code (usually `.ex` files)
  - test: contains tests (usually `.exs` files)
- scripting mode: `.exs` files can be used for scripting. When executed, both `.ex` and `.exs` extensions compile and load their modules into memory, although only `.ex` files write their bytecode to disk in the format of `.beam` files.

### Basic Types
- Elixir basic types: **integers**, **floats**, **booleans**, **atoms**, **strings**, **lists** and **tuples**.
- Elixir data structure is *immutable* -> we can pass the data around without worrying that it's mutated in memory.
- Anonymous functions should be called with a dot (`.`) between between the variable and parentheses. The dot ensures there is no ambiguity between calling the anonymous function matched to a variable and a named function.
- When Elixir sees a list of printable ASCII numbers, Elixir will print that as a **charlist** (a list of characters). 
  ```
  iex(1)> i 'Jenny'
  Term
    'Jenny'
  Data type
    List
  Description
    This is a list of integers that is printed as a sequence of characters
    delimited by single quotes because all the integers in it represent printable
    ASCII characters. Conventionally, a list of Unicode code points is known as a
    charlist and a list of ASCII characters is a subset of it.
  Raw representation
    [74, 101, 110, 110, 121]
  Reference modules
    List
  Implemented protocols
    Collectable, Enumerable, IEx.Info, Inspect, List.Chars, String.Chars
  ```
- Single-quoted and double-quoted representations are different. Single quotes are *charlists*, double quotes are *strings* (*binaries*, to be precise).

  ```
  iex(3)> i "Jenny"
  Term
    "Jenny"
  Data type
    BitString
  Byte size
    5
  Description
    This is a string: a UTF-8 encoded binary. It's printed surrounded by
    "double quotes" because all UTF-8 encoded code points in it are printable.
  Raw representation
    <<74, 101, 110, 110, 121>>
  Reference modules
    String, :binary
  Implemented protocols
    Collectable, IEx.Info, Inspect, List.Chars, String.Chars
  ```
  That's cool!
- Lists vs Tuples
  - Lists are stored in memory as linked lists -> accessing the length of a list is a linear operation.
  - Tuples are stored contiguously in memory -> getting the tuple size or accessing an element by index is fast, but updating or adding elements to tuples is expensive because it requires creating a new tuple in memory.
  - a simple rule when counting the elements in a data structure: the function is named `size` if the operation is in constant time; `length` if the operation is linear.

### Streaming Files
Alas! Here comes the pipes!  

This is the part I'm most excited about Elixir (or functional programming language in general). The pipes. Basically you can throw data into a series of functions, organized in a clear & elegant way, and get the transformed data without making a mess with if-else statements and duplications. 

## Day 02 - (More on) Strings, Maps, and Recursions
### Docs
- https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html
- https://elixir-lang.org/getting-started/recursion.html
- https://elixir-lang.org/getting-started/keywords-and-maps.html


### Strings
- Elixir uses UTF-8 encoding by default. Each letter is assigned to a **code point**. For example, character J has code point 74.
- we can use `String.codepoints/1` to split a string in its individual characters.
- Strings are binaries (in fact, if we look at the info for term "Jenny" above, the data type section says **BitString**.

### Binaries
- is defined using `<<>>`.
- A binary is a sequence of bytes. Can be organized even in sequence that does not make a valid string.
- We can concatenate the null byte `<<0>>` to a string to see its inner binary representation:

	```elixir
	iex> "hełło" <> <<0>>
	<<104, 101, 197, 130, 197, 130, 111, 0>>
	```

### Keyword Lists
- [`Keyword` module](https://hexdocs.pm/elixir/Keyword.html)
- == lists of tuples

	```elixir
	iex> list = [{:a, 1}, {:b, 2}]  
	[a: 1, b: 2]
	iex> list == [a: 1, b: 2]
	true
	```
- Keyword lists are simply lists -> linear performance in key lookup, count operations etc.

### Maps
- [`Map` module](https://hexdocs.pm/elixir/Map.html)
- the primary key-value store data structure.
- created using `%{}` syntax.
- allow any value as keys.
- useful with pattern matching (as long as the keys in the pattern exist in the given map).
- some useful syntax

	```elixir
	map = %{:a => 1, :b => 2}
	
	# fetch
	Map.get(map, :a)
	
	# add
	Map.put(map, :c => 3)
	
	# update
	%{map | :b => "two"}
	%{map | :d => "four"} # => ** (KeyError)
	```
- We can use `.` to access atom keys! (which is the preferred syntax because it leads to an assertive style of programming)

### Nested Data Structures
- Elixir provides `put_in/2`, `update_in/2`, `get_and_update_in/2` for working with nested data structures.
- as well as `put_in/3`, `update_in/3`, `get_and_update_in/3`. 
- learn more (later) in the [`Kernel` module](https://hexdocs.pm/elixir/Kernel.html)


### Loops
- Loops in Elixir (as in any functional programming language) are written differently from imperactive or object-oriented languages because of **immutability**.
- Functional languages rely on recursion–no data is mutated in the process.
- a simple example (and to get more taste of Elixir):

```elixir
defmodule Recursion do
  def print_multiple_times(msg, n) when n <= 1 do
    IO.puts msg
  end

  def print_multiple_times(msg, n) do
    IO.puts msg
    print_multiple_times(msg, n - 1)
  end
end
```

## Day 03 - Data Structure Exploration
### The Puzzle
So the puzzle for day 3 requires a bit of brain. The way I decided to tackle it follows 5 steps:

1. Parse an instruction list, draw each coordinate on a board.
2. Do it twice for both wires.
3. Find all intersections of the two wires. That is, the coordinates that's mapped on both boards.
4. For part 1, return the combined value of the nearest coordinate.
5. For part 2, return the minimum "steps" it takes for two wires to intersect.

### Common Data Collection Types in Elixir
- **lists**
	- [+] ordered array
	- [-] linear time in lookup and inserting (if not from the head)
- **maps**
- [+] fast lookup
- [-] *not exactly sorted
- **map sets**
  - [+] guaranteed uniqueness; fast lookup.
  - [-] *not exactly sorted

\* Small maps are ordered lists where the map has <= 31 entries. When a map gets 32 entries, it changes to a hash trie ([Hash Array Mapped Trie](https://en.wikipedia.org/wiki/Hash_array_mapped_trie)) that has a lookup of O(log n).  
ref: https://stackoverflow.com/questions/35677865/is-map-lookup-in-elixir-o1

### Puzzle implementation
Originally, for part 1 I chose `MapSet` for my two boards, because what I eventually need is just a way to know if the wire has "been there" on the board. Also, `MapSet` provides this `MapSet.intersection/2` function that's handy when retriving the coordinates that both wires have visited on the board. As for part 2, I used `Map` because I need to store an associative value "steps" for each coordinate.

There is (as always) another implementation that solves the two puzzles with more elegance and code reusability. Instead of using different data structures to store the coordinates, `List` can be used to serve both parts. The elegance of storing coordinates in lists is that we automatically gets the index of each coordinate, which is the "steps" we need for part 2, so we don't have to find somewhere to store this information anymore!

### Some Thoughts
I wrote an recursive function `SpaceShip.draw_board/3` as part of my solution. When I tried to search online for best practices, I noticed that it seems to be a convention/preferred design that we use separate same-name methods for different conditions([example](https://gitlab.com/NobbZ/aoc_ex/blob/master/lib/y2019/d3.ex)). That is, we do pattern matching at the function argument-passing level. That eliminates the need for `if/else` statements but also creates another layer of repetition (for example I ended up writing four methods for each recursion). I'm not sure yet how it contributes to readability. But perhaps when I get more familiar with Elixir I'll have more to say on this. We'll see!  

## Day 5 - How does Elixir manage memory?
So this thing has been in my head: how does Elixir manages its memory if all data structures are immutable? Doesn't that mean everytime we try to add a new element into a, say, 5-element list, the memory it takes instantly doubles? After doing some research, I found out this concept called **structural sharing**.

### Structural Sharing
It actuall takes advantage of the recursive nature of Elixir objects.  Using a trie hash map.

### Resources
- https://www.freecodecamp.org/news/elixir-why-linked-lists-aa6828b6b099/
- https://github.com/dt-fe/weekly/issues/14
- https://en.wikipedia.org/wiki/Trie

