
# is this how to import ??
# ... c("mf_practice.ex")
# does it compile the code ??
# because elixirc "filename.ex" is how to compile
# after that do iex and the modules and stuff are availible ?? weird ...

# https://stackoverflow.com/questions/36292620/elixir-when-to-use-ex-and-when-exs-files
# FUN FACT: .ex is for compiled code, .exs is for interpreted code.

defmodule M do
  # elixir does not need a main
  def foo do
    # ask for name input the '\n' trimmed off
    # save that to a variable 'name'
    name = IO.gets("What is your name? ") |> String.trim
    # check out this cool string interpolation
    IO.puts "Hello #{name}"
  end

  def data_stuff() do
    my_int = 123
    IO.puts "Integer? #{is_integer(my_int)}"
    my_float = 1.23
    IO.puts "Float? #{is_float(my_float)}"
    IO.puts "Atom? #{is_atom(:applesauce)}"
    IO.puts "Atom? #{is_atom(:"atom with spaces")}"
    # cool range, eh?
    one_to_10 = 1..10
    hi = "Hello"
    IO.puts "Length: #{String.length(hi)}"
    str2 = hi <> " " <> "World!"
    IO.puts str2
    IO.puts "contains? #{String.contains?(hi, "Hello")}"
    # the === is like javascript, supa dupa strict
    IO.puts "? 'Egg' === 'egg' : #{"Egg" === "egg"}"
    IO.puts "? '1' == '1' : #{"1" == "1"}"
    IO.puts "? '1' === '1' : #{'1' === '1'}"
    IO.puts "? '1' === 1 : #{'1' === 1}"
    IO.puts "? '1' == 1 : #{'1' == 1}"
    # IO
    IO.puts "First : #{String.first(hi)}"
    # inspect is cool for making lists !!!
    IO.inspect String.split(str2, " ")

    # many other string functions of course

    # look at this data passing, "pipes"
    4 * 10 |> IO.puts
  end

  def do_stuff do
    # there are math things, simple ok
    # check out the diff between == and
    # compare data vs compare data + data types
    IO.puts "? '4 == 4.0 : #{4 == 4.0}"
    IO.puts "? '4 === 4.0 : #{4 === 4.0}"
    IO.puts "? '4 != 4.0 : #{4 != 4.0}"
    IO.puts "? '4 !== 4.0 : #{4 !== 4.0}"

    # and, or, not work as you expect
  end

  def control_flow do
    age = 16

    if age >= 18 do
      IO.puts "can vote"
    else
      IO.puts "cannot vote"
    end

    # gaurd statement
    unless age === 18 do
      IO.puts "you are not 18"
    else
      IO.puts "you are 18"
    end

    # but why tho because ...
    if age !== 18 do
      IO.puts "you are not 18"
    else
      IO.puts "you are 18"
    end
  end

  def functions do
    get_sum = fn (x, y) -> x + y end
    foo = get_sum.(2,2) # expect 4
    print = fn (s) -> IO.puts 'foo #{s}' end
    print.("ok")
    IO.puts foo # expect 4
  end
end
