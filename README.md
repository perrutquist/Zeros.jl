# Zeros.jl

[![Build Status](https://travis-ci.org/perrutquist/Zeros.jl.svg?branch=master)](https://travis-ci.org/perrutquist/Zeros.jl)
[![codecov.io](http://codecov.io/github/perrutquist/Zeros.jl/coverage.svg?branch=master)](http://codecov.io/github/perrutquist/Zeros.jl?branch=master)

This module provides a singular datatype named `Zero`. All instances of this datatype are identical, and represent the value zero.

`Zero` is a subtype of `Integer`. The most common operations, such as `+`, `-`, `*`, `/`, `<`, `>`, etc. are defined. Operations like `*` propagate the `Zero` type to their return values in a way that is correct for real numbers, but not for IEEE 754 `Inf` and `NaN`. For example, `Zero()*x` reduces to `Zero()` at compile-time which has the effect that `Zero()*Inf` becomes `Zero()` rather than `NaN`. A value with this behaviour is sometimes referred to a "strong zero".

Since the value of a `Zero` is known at compile-time, the complier might be able to make optimisations when functions are called with arguments of this type. (Since Julia 0.7, literal constants are often propagated into functions at compile-time, and this can have a similar effect, but it might be hard to control which literals are propagated.)

Trying to convert a nonzero value to `Zero` will throw an `InexactError`.

Attempting to divide by `Zero()` will throw a `DivideError` rather than returning `Inf` or `NaN`.
(A compile-time zero in the denominator is usually a sign that a piece of code needs to be re-written to work optimally.)

The `testzero` function can be used to change the type when a variable is equal to zero. For example `foo(testzero(a), b)` will call `foo(a,b)` if `a` is nonzero. But if `a` is zero, then it will call `foo(Zero(),b)` instead. The function `foo` will then be complied specifically for input of the type `Zero` and this might result in speed-ups that outweigh the cost of branching.

New in v0.1: Attempting to create a `Complex` with `Zero()` as its real part will result in a `Real`, which will typically result in faster code execution. (For more advanced usage of `Zero` and complex numbers, see the example below.)

### Usage example: Complex numbers

Julia already has complex numbers, of course, but writing code to handle them makes a good example, since the special cases of real numbers (i.e. complex numbers with imaginary part equal to zero) and imaginary numbers (real part equal to zero) are common enough that we might want to create special types for them.

If we use three different classes for real, imaginary and complex numbers, then we need nine different methods to handle every combination of arguments to binary operator. (For example: real times imaginary, imaginary times complex, etc.) With the `Zero` type, we can define all of these at once. First we define the types and constructors:

```
using Zeros

abstract type MyAbstractComplex{T<:Real} end

struct MyComplex{T<:Real} <: MyAbstractComplex{T}
  re::T
  im::T
end

struct MyReal{T<:Real} <: MyAbstractComplex{T}
  re::T
  im::Zero
end

struct MyImaginary{T<:Real} <: MyAbstractComplex{T}
  re::Zero
  im::T
end

MyReal(re::T) where {T<:Real} = MyReal{T}(re, Zero())
MyImaginary(im::T) where {T<:Real} = MyImaginary{T}(Zero(), im)
MyComplex(re::Real, im::Zero) = MyReal(re)
MyComplex(re::Zero, im::Real) = MyImaginary(im)
MyComplex(::Zero, ::Zero) = MyComplex{Zero}(Zero(), Zero()) # disambiguation
```
It is worth noting that `Zero` does not require any storage, so `MyReal` and `MyImaginary` require half the storage of `MyComplex`.

Having defined the three types to all have the same fields, we can now define functions and for all using the abstract type. For example, we can define multiplication as:
```
Base.:*(x::MyAbstractComplex, y::MyAbstractComplex) =
    MyComplex(x.re*y.re - x.im*y.im, x.re*y.im + x.im*y.re)
```
This defines multiplication for all combinations of `MyReal`, `MyImaginary` and `MyComplex`.
We can now try multiplying two purely imaginary numbers:
```
julia> MyImaginary(2)*MyImaginary(3)
MyReal{Int64}(-6, 0̸)
```
Through the magic of type inference, Julia has figured out that imaginary times imaginary equals real,
and the result is computed just as efficiently as if we had hand-coded `*(a::MyImaginary, b::MyImaginary)`.

### Another example

Another use for the `Zero` type can be found in [DoubleDoubles.jl](https://github.com/perrutquist/DoubleDoubles.jl).
It defines a `Double` type which has a `.hi` and a `.lo` field. The case where the `.lo` field is zero is common enough that a separate type `Single` is defined for this. Instead of a type with no `.lo` field, we create one where it is of the `Zero` type (and thus requires no storage).

Existing functions may require some modifications to work with the `Zero` type. In particular, type assertions might be too restrictive.
