# Zeros.jl

[![Build Status](https://travis-ci.org/perrutquist/Zeros.jl.svg?branch=master)](https://travis-ci.org/perrutquist/Zeros.jl)
[![codecov.io](http://codecov.io/github/perrutquist/Zeros.jl/coverage.svg?branch=master)](http://codecov.io/github/perrutquist/Zeros.jl?branch=master)

This module provides the datatype `Zero`. All instances of this datatype are identical, and represent the value zero. (The term "singular datatype" might be appropriate if it was not already used for another concept in julia.)

`Zero` is a subtype of `Real`. The most common operations for real values, such as `+`, `-`, `*`, `/`, `<`, `>`, etc. are defined. Operations like `*` propagate the `Zero` type to their return values.

`Complex(Zero(),Zero())` can be used to represent a complex value equal to zero.

Trying to convert a nonzero value to `Zero` will throw an `InexactError`.

Since the value of a `Zero` is known at compile-time, the complier might be able to make optimizations when functions are called with arguments of this type. For example, in Julia 0.6.0-rc1.0, filling a `Float64` array with zeroes using `A .= Zero()` is twice as fast as `A .= 0.0` one some systems. This is because the `fill!` function gets re-compiled with the constant `Float64(0)`, and the compiler recognizes that it consists of four identical bytes, and the whole operation can be performed with a `llvm.memset` instead of an explicit loop.

The function `zero!(A)` can be used as an alias for `fill(A, Zero())` to quickly fill a real or complex array with zeros.

The `testzero` function can be used to change the type when a variable is equal to zero. For example `foo(testzero(a), b)` will call `foo(a,b)` if `a` is nonzero. But if `a` is zero, then it will call `foo(Zero(),b)` instead. The function `foo` will then be complied specifically for input of the type `Zero` and this might result in speed-ups that outweigh the cost of branching.

### Use as a field in a struct

Another use for the `Zero` type can be found in [DoubleDoubles.jl](https://github.com/perrutquist/DoubleDoubles.jl).
It defines a `Double` type which has a `.hi` and a `.lo` field. The case where the `.lo` field is zero is common enough that a separate type `Single` is defined for this. Instead of a type with no `.lo` field, we create one where it is of the `Zero` type (and thus requires no storage). The code in that module looks like this:
```
abstract AbstractDouble{T} <: AbstractFloat
immutable Double{T<:AbstractFloat} <: AbstractDouble{T}
    hi::T
    lo::T
end
immutable Single{T<:AbstractFloat} <: AbstractDouble{T}
    hi::T
    lo::Zero
end
```
Since the two subtypes have the same fields we can write methods for the abstract type, and they will work with either concrete type.

(Existing functions may require some modifications to work with the `Zero` type. In particular, type assertions might be too restrictive.)
