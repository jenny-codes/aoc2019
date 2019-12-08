# Advent of Code 2019 with Elixir!
- Decided to learn Elixir while doing the AOC challenge. Learn and enjoy the puzzles at the same time!
- AOC website: https://adventofcode.com/2019

# Elixir Learning Notes
- Elixir website: https://elixir-lang.org
- This document is organized around the puzzles for each day.

## The Basics
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
- Single-quoted and double-quoted representations are different. Single quotes are *charlists*, double quotes are *strings*.
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
  
