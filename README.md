# Zeros.jl

[![Build Status](https://github.com/perrutquist/Zeros.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/perrutquist/Zeros.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![codecov.io](http://codecov.io/github/perrutquist/Zeros.jl/coverage.svg?branch=master)](http://codecov.io/github/perrutquist/Zeros.jl?branch=master)

This module provides singular datatypes named Zero and One. All instances of each datatype are identical, and represent the values zero and one, respectively. This is a light-weight alternative to [StaticNumbers.jl](https://github.com/perrutquist/StaticNumbers.jl) when only these two values are needed.

`Zero` and `One` are subtypes of `Integer`. The most common operations, such as `+`, `-`, `*`, `/`, `<`, `>`, etc. are defined. Operations like `*` propagate the `Zero` or `One` type to their return values in a way that is correct for numbers, but not for IEEE 754 `Inf` and `NaN`. For example, `Zero()*x` reduces to `Zero()` at compile-time which has the effect that `Zero()*Inf` becomes `Zero()` rather than `NaN`. A value with this behaviour is sometimes referred to as a "strong zero".

Since the value of a `Zero` or `One` is known at compile-time, the complier might be able to make optimisations that might not be possible otherwise.

With Julia v1.3 and later, the Unicode symbols `𝟎` and `𝟏` can be used as aliases for `Zero()` and `One()`. These can be entered from the keyboard as `\bfzero` or `\bfone` followed by a tab. (User beware: Depending on the font used, it might be hard to tell the difference between these symbols and the numbers `0` and `1`.)

Trying to convert a nonzero value to `Zero` will throw an `InexactError`.

Attempting to divide by `Zero()` will throw a `DivideError` rather than returning `Inf` or `NaN`.
(A compile-time zero in the denominator is usually a sign that a piece of code needs to be re-written to work optimally.)

The `testzero` function can be used to change the type when a variable is equal to zero. For example `foo(testzero(a), b)` will call `foo(a,b)` if `a` is nonzero. But if `a` is zero, then it will call `foo(Zero(),b)` instead. The function `foo` will then be complied specifically for input of the type `Zero` and this might result in speed-ups that outweigh the cost of branching.

The command
```
Zeros.@pirate Base
```
can be used to enable a few more (rarely needed) method definitions, such as `+()` (the sum of zero terms)
and `*()` (the product of zero factors).
