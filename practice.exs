# module stores all function
defmodule MyModule do
    def main do
        # name = IO.gets("What is your name? ") |> String.trim
        # IO.puts "Hello #{name}"
        list()
    end

    def data_stuff do
        # int type
        # my_int = 123
        # IO.puts "Integer #{is_integer(my_int)}"

        # float type
        # my_float = 3.1456
        # IO.puts "Float #{is_float(my_float)}"

        # atom type: the name is the same as the value
        IO.puts "Atom #{is_atom(:Pittsburgh)}"
    end

    def do_stuff do
        my_str = "My Sentence"
        IO.puts "Length: #{String.length(my_str)}"
        longer_str = my_str <> " " <> "is longer"

        # Strings
        IO.puts "Equal : #{"Egg" === "egg"}"
        IO.puts "My ? #{String.contains?(my_str, "My")}"
        IO.puts "First: #{String.first(my_str)}"
        IO.puts "Index 4: #{String.at(my_str, 4)}"
        IO.puts "Substring: #{String.slice(my_str, 3, 8)}"

        # inspect a string (see the internal representation)
        IO.inspect String.split(longer_str, " ")

        # piping
        4 * 10 |> IO.puts
    end

    def do_math do
        IO.puts "5 + 4 = #{5+4}"
        IO.puts "5 - 4 = #{5-4}"
        IO.puts "5 * 4 = #{5*4}"
        IO.puts "5 / 4 = #{5/4}"
        IO.puts "5 div 4 = #{div(5, 4)}"
        IO.puts "5 rem 4 = #{rem(5, 4)}"
    end

    def equality_operators do
        IO.puts "4 == 4.0 : #{4 == 4.0}"

        # compare the values and the data type (int vs. float)
        IO.puts "4 === 4.0 : #{4 === 4.0}"
        IO.puts "4 != 4.0 : #{4 != 4.0}"
        IO.puts "4 !== 4.0 : #{4 !== 4.0}"
    end

    def logical_operators do
        age = 16
        IO.puts "Vote and drive: #{(age >= 16) and (age >= 18)}"
        IO.puts "Vote or drive: #{(age >= 16) or (age >= 18)}"
    end

    def conditionals do
        age = 16

        # if statement
        if age >= 18 do
            IO.puts "Can vote"
        else
            IO.puts "Can't vote"
        end

        # unless statement
        unless age === 18 do
            IO.puts "You are not 18"
        else 
            IO.puts "You are 18"
        end

        # cond statements
        cond do 
            age >= 18 -> IO.puts "You can vote" 
            age >= 16 -> IO.puts "You can drive"
            age >= 14 -> IO.puts "You can wait"
            true -> IO.puts "Default"
        end

        # case statement (like match)
        case 2 do
            1 -> IO.puts "Entered 1"
            2 -> IO.puts "Entered 2"
            _ -> IO.puts "Default"
        end
    end

    def tuples do
        my_stats = {175, 6.25, :Derek}
        IO.puts "Tuple #{is_tuple(my_stats)}"

        my_stats2 = Tuple.append(my_stats, 42)
        IO.puts "Age #{elem(my_stats2, 3)}"
        IO.puts "Size: #{tuple_size(my_stats2)}"
        my_stats3 = Tuple.delete_at(my_stats2, 0)
        many_zeroes = Tuple.duplicate(0, 5)
        {weight, height, name} = {175, 6.25, "Derek"}
        IO.puts "Weight: #{weight}"
    end

    def lists do
        list1 = [1,2,3]
        list2 = [4,5,6]
        list3 = list1 ++ list2
        list4 = list3 -- list1

        IO.puts 6 in list4

        # very first item in list is head
        [head | tail] = list3
        IO.puts "Head: #{head}"
        IO.write "Tail: "
        IO.inspect tail

        IO.inspect [97, 98], char_lists: :as_lists

        Enum.each tail, fn item ->
            IO.puts item
        end

        words = ["Random", "Words", "in"]
        Enum.each words, fn word ->
            IO.puts word
        end

        IO.inspect List.insert_at(words, 3, "Yeah")
        IO.puts List.first(words)
        IO.puts List.last(words)

        # recursion to loop as well
        display_list_rec(words)
    end

    # recursion of list
    def display_list_rec([word | words]) do
        IO.puts word
        display_list_rec(words)
    end
    def display_list_rec([]), do: nil

    # maps
    def maps do
        capitals = %{"Alabama" => "Montgomery",
            "Alaska" => "Juneau", "Arizona" => "Pheonix"}

        IO.puts "Capital of Alaska is #{capitals["Alaska"]}"

        capitals2 = %{alabama: "Montgomery",
            alaska: "Juneau", arizona: "Pheonix"}
        IO.puts "Capital of arizona is #{capitals2.arizona}"
    end

    #pattern matching
    def pattern_matching do
        [length, width] = [20, 30]
        IO.puts "Width: #{width}"

        [_, [_, a]] = [20, [30, 40]]
        IO.puts "Get num: : #{a}"
    end

    def stuff do 
        add_sum = fn
            {x, y} -> IO.puts "#{x} + #{y} = #{x+y}"
            {x, y, z} -> IO.puts "#{x} + #{y} + #{z} = #{x+y+z}"
        end
    end

    def looping do
        IO.puts "Sum : #{sum([1,2,3])}"

        loop(5, 1)
    end

    # recursively sum values of a list
    def sum([]), do: 0
    def sum([h | t]), do: h + sum(t)


end