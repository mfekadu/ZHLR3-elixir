
  # NumC ExprC Struct Definition -- Add more ExprC later
  defmodule NumC do
    defstruct value: -1
  end

  # IdC ExprC Struct Definition -- Add more ExprC later
  defmodule IdC do
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
  defmodule PrimC do
    defstruct operator: 0, function: 0
  end


defmodule Main do

  def parse(n) do
    cond do
      is_integer(n) -> %NumC{value: n}
      is_atom(n) -> %IdC{value: n}
    end
    # IO.puts num.value #Printing
  end

  # given ExprC and environment, output a Value
  def interp(expr, env) do
    case expr do
      %NumC{} -> %NumV{value: expr.value}
      %IdC{} -> envlookup(env, expr.value)
    end
  end

  # given Value, return String
  def serialize(v) do
    case v do
      %NumV{} -> IO.puts v.value
      'myadd' -> IO.puts 'matched myadd'
    end
  end

  def myadd(l, r) do
    case [l, r] do
      [%NumC{}, %NumC{}] -> l.value + r.value
      _ -> "Error"
    end
  end

  def extend_env(env, sym, val) do
    Map.put(env, sym, val)
  end

  def topEnv() do
    te = extend_env(%Environment{}.bindings, :+, 'myadd')
    te
  end

  def envlookup(env, sym) do
    Map.get(env, sym)
  end



  # given s, evaluate the s
  def topInterp(s) do
    serialize(interp(parse(s), topEnv()))
    myadd(%NumC{value: 3}, %NumC{value: 3})
  end
end

IO.puts Main.topInterp(8)
Main.topInterp(:+)
