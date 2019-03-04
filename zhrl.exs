
  # NumC ExprC Struct Definition -- Add more ExprC later
  defmodule NumC do
    defstruct value: nil
  end

  defmodule IfC do
    defstruct test: nil, then: nil, else: nil
  end

  # IdC ExprC Struct Definition -- Add more ExprC later
  defmodule IdC do
    defstruct value: nil
  end

  # StringC ExprC Struct Definition -- Add more ExprC later
  defmodule StringC do
    defstruct value: nil
  end

  # LamC ExprC Struct Definition
  defmodule LamC do
    defstruct args: nil, body: nil
  end

  # Number Value Struct Definition -- Add more Value later
  defmodule NumV do
    defstruct value: nil
  end

  # StringV Value Struct Definition -- Add more Value later
  defmodule StringV do
    defstruct value: nil
  end

  # Closure Value Struct Definition -- Add more Value later
  defmodule CloV do
    defstruct params: nil, body: nil, env: nil
  end

  defmodule BoolV do
    defstruct bool: false
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
      is_binary(n) -> %StringC{value: n}
      # default case
      true -> case n do
          ['lam', a, b] -> %LamC{args: a, body: b}
          ['if', a, b, c] -> %IfC{test: parse(a), then: parse(b), else: parse(c)}
      end
    end
  end

  # given ExprC and environment, output a Value
  def interp(expr, env) do
    case expr do
      %NumC{} -> %NumV{value: expr.value}
      %IdC{} -> envlookup(env, expr.value)
      %IfC{} -> i = interp(expr.test, env)
                then = interp(expr.then, env)
                els = interp(expr.else, env)
                case i do
                  %BoolV{} -> case i.bool do
                                true -> then
                                false -> els
                              end
                  _ -> "ZHRL: test expression must evaluate to boolean"
                end
      %StringC{} -> %StringV{value: expr.value}
      %LamC{} -> %CloV{params: expr.args, body: expr.body, env: env}
    end
  end

  # given Value, return String
  def serialize(v) do
    case v do
      %NumV{} -> IO.puts v.value
      %StringV{} -> IO.puts v.value
      'myadd' -> IO.puts 'matched myadd'
      %BoolV{} -> IO.puts v.bool
    end
  end

# Primitive wrapper functions
  def myadd(l, r) do
    case [l, r] do
      [%NumC{}, %NumC{}] -> l.value + r.value
      _ -> raise "ZHRL: Unable to add"
    end
  end

  def mysub(l, r) do
    case [l, r] do
      [%NumC{}, %NumC{}] -> l.value - r.value
      _ -> raise "ZHRL: Unable to subtract"
    end
  end

  def mymult(l, r) do
    case [l, r] do
      [%NumC{}, %NumC{}] -> l.value * r.value
      _ -> raise "ZHRL: Unable to multiply"
    end
  end

  def mydiv(l, r) do
    case [l, r] do
      [%NumC{}, %NumC{}] -> unless r.value === 0 do
        l.value / r.value end
      _ -> raise "ZHRL: Unable to divide"
    end
  end

  def mylesseq(l, r) do
    case [l, r] do
      [%NumC{}, %NumC{}] -> l.value <= r.value
    end
  end

  def myeq(l, r) do
    case [l, r] do
      [%NumC{}, %NumC{}] -> l.value === r.value
    end
  end

  def extend_env(env, sym, val) do
    env = Map.put(env, sym, val)
    env
  end

  def topEnv() do
    te = extend_env(%Environment{}.bindings, :+, 'myadd')
    te = extend_env(te, :-, 'mysub')
    te = extend_env(te, :*, 'mymult')
    te = extend_env(te, :/, 'mydiv')
    te = extend_env(te, :<=, 'mylesseq')
    te = extend_env(te, :equal?, 'myeq')
    te = extend_env(te, :true, %BoolV{bool: true})
    te = extend_env(te, :false, %BoolV{bool: false})
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


defmodule TestParse do
  def testIf do
    sexp = ['if', true, 0, 1]
    result = Main.parse(sexp)
    expected = %IfC{
      else: %NumC{value: 1},
      test: %IdC{value: true},
      then: %NumC{value: 0}
    }
    unless result === expected do
      raise "TestParse: testIf: fail1"
    end
  end
  def testLam do
    sexp = ['lam', ['x', 'y'], ['+', 'x', 'y']]
    result = Main.parse(sexp)
    expected = %LamC{args: ['x','y'], body: ['+','x','y']}
    unless result === expected do
      raise "TestParse: testLam: fail1"
    end
  end
  def testAll do
    testIf()
    testLam()
  end
end

defmodule TestInterp do
  def testIf do
    # 'IfC.test' is true, therefore expect NumV.value to be '0'
    expr = %IfC{
      else: %NumC{value: 1},
      test: %IdC{value: true},
      then: %NumC{value: 0}
    }
    topEnv = Main.topEnv()
    result = Main.interp(expr, topEnv)
    expected = %NumV{value: 0}
    unless result === expected do
      raise "TestInterp: testIf: fail1"
    end
    # 'IfC.test' is false, therefore expect NumV.value to be '1'
    expr = %IfC{
      else: %NumC{value: 1},
      test: %IdC{value: false},
      then: %NumC{value: 0}
    }
    topEnv = Main.topEnv()
    result = Main.interp(expr, topEnv)
    expected = %NumV{value: 1}
    unless result === expected do
      raise "TestInterp: testIf: fail2"
    end
  end
  def testLam do
    lam_x_y_plus = %LamC{args: ['x','y'], body: ['+','x','y']}
    topEnv = Main.topEnv()
    result = Main.interp(lam_x_y_plus, topEnv)
    expected = %CloV{params: lam_x_y_plus.args, body: lam_x_y_plus.body, env: topEnv}
    unless result === expected do
      raise "TestInterp: testLam: fail1"
    end
  end
  def testAll do
    testIf()
    testLam()
  end
end

IO.puts Main.topInterp(8)
IO.inspect Main.parse(['if', 6 > 5, 1, 0])
IO.inspect Main.parse(['if', 5 > 6, 6 > 5, 0])
IO.puts Main.topInterp("Hello, World")
Main.topInterp(:+)
TestParse.testAll()
TestInterp.testAll()
