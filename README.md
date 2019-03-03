# ZHLR3-elixir
implementing ZHRL3 with elixir

## structs
* ExprC
```racket
;===============================================================================
; Language struct definitions
;;;;;;;;;;;;;;;;;;;;;;;;;
(define-type ExprC (U NumC IdC StringC If LamC AppC Real))
(struct NumC ([n : Real]) #:transparent)
(struct IdC ([s : Symbol]) #:transparent)
(struct StringC ([s : String]) #:transparent)
(struct LamC ([args : (Listof Symbol)] [body : ExprC]) #:transparent)
(struct If ([tst : ExprC] [thn : ExprC] [els : ExprC]) #:transparent)
(struct AppC ([fun : ExprC] [args : (Listof ExprC)]) #:transparent)
;===============================================================================
```
* Env (Atom -> Value)
```
; Environment type, aliases, and functions for managing the environment
;;;;;;;;;;;;;;;;;;;;;;;;;
(define-type Env (Immutable-HashTable Symbol Value))

(define mt-env : Env (make-immutable-hash))

(define (extend-env [env : Env] [name : Symbol] [value : Value]) : Env
  (hash-set env name value))
```
* Value
```
;===============================================================================
; Value struct definitions
;;;;;;;;;;;;;;;;;;;;;;;;;
(define-type Value (U NumV StringV BoolV CloV PrimV))
(struct NumV ([n : Real]) #:transparent)
(struct StringV ([s : String]) #:transparent)
(struct BoolV ([b : Boolean]) #:transparent)
(struct CloV ([params : (Listof Symbol)] [body : ExprC] [env : Env]) #:transparent)
(struct PrimV ([op : (-> Value Value Value)]) #:transparent)
;===============================================================================
```

## functions

### top-interp

```racket
;===============================================================================
; given an S-expression, interpret and output the resulting Value as a String
(define (top-interp [s : Sexp]) : String
  (serialize (interp (parse s) top-env)))
;===============================================================================
```

### interp
```racket
;===============================================================================
; interp - interpret an expression in a given Environment
; given ExprC and Environment returns Value
;;;;;;;;;;;;;;;;;;;;;;;;;
(define (interp [exp : ExprC] [env : Env]) : Value
  (match exp
    [(IdC n) (lookup n env)]                    ; binding
    [(NumC n) (NumV n)]                         ; number
    [(StringC t) (StringV t)]                   ; string
    [(If tst thn els)                           ; conditional
     (match (interp tst env)
       [(BoolV #t) (interp thn env)]
       [(BoolV #f) (interp els env)]
       [else (ZHRLerror TEST_COND_IS_NOT_BOOL_MSG)])]
    [(LamC params body) (CloV params body env)] ; closure
    [(AppC (IdC op) (list l r))
       #:when (primop? op)
       ((get-prim-func op env) (interp l env) (interp r env))]  ; primitive
    [(AppC fun args)
     (define fun-val (interp fun env))
     (match fun-val
       [(CloV params body clo-env)              ; match (AppC (LamC ..)..)
        (define parent-env env)
        (interp body (extend-clo-env body params args clo-env parent-env))]
       [_ (ZHRLerror UNEXPECTED_MSG)])]))
;===============================================================================
```
### parse
```racket
;===============================================================================
; parse - parse an expression
; given Sexp returns ExprC
;;;;;;;;;;;;;;;;;;;;;;;;;
(define (parse [s : Sexp]) : ExprC
  (match s
    [(? real? n) (NumC n)]      ; match 42, '42
    [(? symbol? x) (catch-reserved-non-primitive x) (IdC x)] ; match 'foo (non-reserved)
    [(? string? t) (StringC t)] ; match "foo"
    [(list 'lam (list (? symbol? ids) ...) expr) ; match lam
     (if (check-duplicates ids) (ZHRLerror DUPLICATE_LAM_MSG) null)
     (LamC (toSymList ids) (parse expr))]
    [(list 'lam _ ...) (ZHRLerror BAD_LAMBDA_PARAMS)] ; catch all unexpected 'lam expressions
    [(list 'var (list (? symbol? ids) '= exprs) ... body) ; match var
     (if (check-duplicates ids) (ZHRLerror DUPLICATE_VAR_MSG) null)
     (create-app-lam (toSymList ids) (toSexpList exprs) body)]
    [(list 'if tst thn els) (If (parse tst) (parse thn) (parse els))] ; match if
    [(list (? symbol? fun) args ...) ; match function definition
     (cond
       [(and (reserved? (toSym fun)) (not (= (length args) 2))) (ZHRLerror BAD_ARITY_MSG)]
       [(AppC (IdC (toSym fun)) (map parse args))])]
    [(list fun args ...) (AppC (parse fun) (map parse args))] ; match function application
    [_ (ZHRLerror UNEXPECTED_MSG)]
))
;===============================================================================
```

### serialize
```racket
;===============================================================================
; given a Value, return the String representation
(define (serialize [v : Value]) : String
  (match v
    [(NumV n) (~v n)]
    [(StringV s) s]
    [(BoolV b) (if b "true" "false")]
    [(? CloV? c) "#<procedure>"]
    [_ (~a "unexpected value :" (~v v))]))
;===============================================================================
```
