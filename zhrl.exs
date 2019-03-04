
  # NumC ExprC Struct Definition -- Add more ExprC later
  defmodule NumC do
    defstruct value: -1
  end

  # NumC Value Struct Definition -- Add more Value later
  defmodule NumV do
    defstruct value: -1
  end

  # An environment
  defmodule Environment do
    defstruct bindings: %{} # Empty Map
  end

  # A PrimV
  defmodule PrimV do
    defstruct operator: 0, function: 0
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
      %NumC{} -> %NumV{value: e.value}
    end
  end

  # given Value, return String
  def serialize(v) do
    case v do
      %NumV{} -> IO.puts v.value
    end
  end

  def myadd(l, r) do
    case [l, r] do
      [%NumC{}, %NumC{}] -> l.value + r.value
      _ -> "Error"
    end
  end

  # given s, evaluate the s
  def topInterp(s) do
    extend_env = fn (env, sym, val) -> Map.put(env, sym, val) end
    extend_env.(%Environment{}.bindings, :+, :myadd)
    serialize(interp(parse(s)))
    myadd(%NumC{value: 3}, %NumC{value: 3})
  end
end

IO.puts Main.topInterp(8)
