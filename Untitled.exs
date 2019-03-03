
#NumC Struct Definition -- Add more ExprC later
  defmodule NumC do
    defstruct value: -1
  end



defmodule Main do
  def parse(n) do
    num = %NumC{value: n}
    num
    # IO.puts num.value #Printing
  end

  # given ExprC, output a Value
  def interp(e) do
    case e do
      %NumC{} -> "numC"
    end
  end

  # given s, evaluate the s
  def topInterp(s) do
    interp(parse(s))
  end
end

IO.puts Main.topInterp(8)
