"""
    Zeros.@pirate Base

Extend some functions in Base to return `Zero()` or `One()`, even when called without
any arguments of types "owned" by Zeros.jl. (This is sometimes referred to as "type piracy".)

The function calls `+()` and `*()` (without arguments) will return `Zero()` and `One()`
respectively. The same will be true for `zero()` and `one()` without arguments.

The functions `zero(Any)` and `one(Any)` will also return `Zero()` and `One()`, respectively,
which in turn will make `sum([])` and `prod([])` return those values.

Finally, `sin(π)` and `tan(π)` will return `Zero()`, fixing a bug in Base.
"""
macro pirate(m::Symbol)
    esc(pirate_code(Val(m)))
end

pirate_code(::Val{:Base}) = quote
   Base.:+() = Zero()
   Base.:*() = One()
   Base.zero() = Zero()
   Base.one() = One()
   Base.zero(::Type{Any}) = Zero()
   Base.one(::Type{Any}) = One()
   Base.sin(::Irrational{:π}) = Zero()
   Base.tan(::Irrational{:π}) = Zero()
end
