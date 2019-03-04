# Language struct definitions -----------------------------------------------

# NumC ExprC Struct Definition
defmodule NumC do
  # (struct NumC ([n : Real]) #:transparent)
  defstruct value: nil
end

defmodule IfC do
  # (struct If ([tst : ExprC] [thn : ExprC] [els : ExprC]) #:transparent)
  defstruct test: nil, then: nil, else: nil
end

# IdC ExprC Struct Definition
defmodule IdC do
  # (struct IdC ([s : Symbol]) #:transparent)
  defstruct value: nil
end

# StringC ExprC Struct Definition
defmodule StringC do
  # (struct StringC ([s : String]) #:transparent)
  defstruct value: nil
end

# LamC ExprC Struct Definition
defmodule LamC do
  # (struct LamC ([args : (Listof Symbol)] [body : ExprC]) #:transparent)
  defstruct args: nil, body: nil
end

defmodule AppC do
  # (struct AppC ([fun : ExprC] [args : (Listof ExprC)]) #:transparent)
  defstruct fun: nil, args: nil
end

# Value struct definitions -----------------------------------------------
# Number Value
defmodule NumV do
  # (struct NumV ([n : Real]) #:transparent)
  defstruct value: nil
end
# String Value
defmodule StringV do
  # (struct StringV ([s : String]) #:transparent)
  defstruct value: nil
end
# Closure Value
defmodule CloV do
  # (struct CloV ([params : (Listof Symbol)] [body : ExprC] [env : Env]) #:transparent)
  defstruct params: nil, body: nil, env: nil
end
# Boolean value
defmodule BoolV do
  # (struct BoolV ([b : Boolean]) #:transparent)
  defstruct bool: false
end
# A Primitive operator
defmodule PrimV do
  # (struct PrimV ([op : (-> Value Value Value)]) #:transparent)
  defstruct operator: 0
end

# An environment struct definition ------------------------------------------
defmodule Environment do
  # (define-type Env (Immutable-HashTable Symbol Value))
  defstruct bindings: %{} # Empty Map
end


defmodule ZHRL do
  # parse - parse an expression
  # given Sexp returns ExprC
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

  # Primitive wrapper functions -----------------------------------------------
  # given left and right Values, return addition of them
  def myadd(l, r) do
    case [l, r] do
      [%NumV{}, %NumV{}] -> %NumV{value: l.value + r.value}
      _ -> raise "ZHRL: Unable to add"
    end
  end
  # given left and right Values, return subtraction of them
  def mysub(l, r) do
    case [l, r] do
      [%NumV{}, %NumV{}] -> %NumV{value: l.value - r.value}
      _ -> raise "ZHRL: Unable to subtract"
    end
  end
  # given left and right Values, return multiplication of them
  def mymult(l, r) do
    case [l, r] do
      [%NumV{}, %NumV{}] -> %NumV{value: l.value * r.value}
      _ -> raise "ZHRL: Unable to multiply"
    end
  end
  # given left and right Values, return division of them
  def mydiv(l, r) do
    case [l, r] do
      [%NumV{}, %NumV{}] -> unless r.value === 0 do
        %NumV{value: l.value / r.value} end
      _ -> raise "ZHRL: Unable to divide"
    end
  end
  # given left and right Values, return Value true if <= else false
  def mylesseq(l, r) do
    case [l, r] do
      [%NumV{}, %NumV{}] -> %BoolV{bool: l.value <= r.value}
    end
  end
  # given left and right Values, return Value true if === else false
  def myeq(l, r) do
    case [l, r] do
      [%NumV{}, %NumV{}] -> %BoolV{bool: l.value === r.value}
    end
  end

  # Environment helper functions ----------------------------------------------
  # given Environment, Symbol, Value; return env with sym => val binding added
  def extend_env(env, sym, val) do
    env = Map.put(env, sym, val)
    env
  end
  # make Env with built-in bindings for primitive operations and symbols
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
  # get the given symbol in the environment
  def envlookup(env, sym) do
    Map.get(env, sym)
  end

  # given an elixir datatype or array of ZHRL syntax, evaluate the ZHRL result
  def topInterp(s) do
    serialize(interp(parse(s), topEnv()))
  end
end


defmodule TestParse do
  def testIf do
    sexp = ['if', true, 0, 1]
    result = ZHRL.parse(sexp)
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
    result = ZHRL.parse(sexp)
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
    topEnv = ZHRL.topEnv()
    result = ZHRL.interp(expr, topEnv)
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
    topEnv = ZHRL.topEnv()
    result = ZHRL.interp(expr, topEnv)
    expected = %NumV{value: 1}
    unless result === expected do
      raise "TestInterp: testIf: fail2"
    end
  end
  def testLam do
    lam_x_y_plus = %LamC{args: ['x','y'], body: ['+','x','y']}
    topEnv = ZHRL.topEnv()
    result = ZHRL.interp(lam_x_y_plus, topEnv)
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

defmodule Main do
  ZHRL.topInterp(8)
  ZHRL.myadd(%NumV{value: 3}, %NumV{value: 3})
  IO.inspect ZHRL.parse(['if', 6 > 5, 1, 0])
  IO.inspect ZHRL.parse(['if', 5 > 6, 6 > 5, 0])
  IO.puts ZHRL.topInterp("Hello, World")
  ZHRL.topInterp(:+)
  TestParse.testAll()
  TestInterp.testAll()
end
