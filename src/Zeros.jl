module Zeros

import Base: +, -, *, /, <, >, <=, >=, fma, muladd, mod, rem, modf,
     ldexp, copysign, flipsign, sign, round, floor, ceil, trunc,
     promote_rule, convert, show, significand, isodd, iseven, scale!

export Zero, testzero, zero!

 "A type that stores no data, and holds the value zero."
immutable Zero <: Real
end

const complexzero = Complex(Zero(), Zero())

promote_rule{T<:Number}(::Type{Zero}, ::Type{T}) = T

convert(::Type{Zero}, ::Zero) = Zero()
convert{T<:Number}(::Type{T}, ::Zero) = zero(T)
convert{T<:Number}(::Type{Zero}, x::T) = x==zero(T) ? Zero() : throw(InexactError())

# (Some of these rules do not handle Inf and NaN according to the IEEE spec.)

+(x::Real,::Zero) = x
+(::Zero,x::Real) = x
+(x::Complex,::Zero) = x
+(::Zero,x::Complex) = x
+(::Zero,::Zero) = Zero()

-(x::Real,::Zero) = x
-(::Zero,x::Real) = -x
-(x::Complex,::Zero) = x
-(::Zero,x::Complex) = -x
-(::Zero,::Zero) = Zero()

*(::Number,::Zero) = Zero()
*(::Zero,::Number) = Zero()
*(::Zero,::Zero) = Zero()
*(::Zero, ::Complex) = complexzero
*(::Complex, ::Zero) = complexzero
*(::Zero, ::Complex{Bool}) = complexzero
*(::Complex{Bool}, ::Zero) = complexzero

/(::Zero,::Real) = Zero()
/(::Zero,::Complex) = complexzero
/(::Real, ::Zero) = throw(DivideError())
/(::Complex, ::Zero) = throw(DivideError())
/(::Zero, ::Zero) = throw(DivideError())
/(::Zero, ::Complex{Zero}) = throw(DivideError())
/(::Real, ::Complex{Zero}) = throw(DivideError())
/(::Complex, ::Complex{Zero}) = throw(DivideError())

<(::Zero,::Zero) = false
>(::Zero,::Zero) = false
>=(::Zero,::Zero) = true
<=(::Zero,::Zero) = true

ldexp(::Zero, ::Integer) = Zero()
copysign(::Zero,::Real) = Zero()
flipsign(::Zero,::Real) = Zero()
modf(::Zero) = (Zero(), Zero())

# Alerady working due to default definitions:
# ==, !=, abs, isinf, isnan, isinteger, isreal, isimag,
# signed, unsigned, float, big, complex

for op in [:(-), :sign, :round, :floor, :ceil, :trunc, :significand]
  @eval $op(::Zero) = Zero()
end

for op in [:fma :muladd]
  @eval $op(::Zero, ::Zero, ::Zero) = Zero()
  @eval $op(::Zero, ::Real, ::Zero) = Zero()
  @eval $op(::Real, ::Zero, ::Zero) = Zero()
  @eval $op(::Zero, x::Real, y::Real) = convert(promote_type(typeof(x),typeof(y)),y)
  @eval $op(x::Real, ::Zero, y::Real) = convert(promote_type(typeof(x),typeof(y)),y)
end

for op in [:mod, :rem]
  @eval $op(::Zero, ::Real) = Zero()
end

isodd(::Zero) = false
iseven(::Zero) = true

# Display Zero() as `0̸` (unicode "zero with combining long solidus overlay")
# so that it looks slightly different from `0`.
show(io::IO, ::Zero) = print(io, "0̸")

"Convert to Zero() if zero. (Use immediately before calling a function.)"
# This function is intentionally not type-stable.
testzero(x::Real) = x==zero(x) ? Zero() : x
testzero(x::Complex) = x==zero(x) ? Complex(Zero(),Zero()) : x

"Fill an array with zeros."
zero!{T<:Real}(a::Array{T}) = fill!(a, Zero())
@generated function zero!{T<:Real}(a::Array{Complex{T}})
  if isbits(T)
    :( zero!(reinterpret(T,a)); return a )# Faster on jula 0.6.0-rc1
  else
    :( fill!(a, complexzero); return a ) # default method
  end
end

# Map scale! to zero! because some impelmentations converts the argument early.
scale!{T<:Real}(a::Array{T}, ::Zero) = zero!(a)
scale!{T<:Real}(::Zero, a::Array{T}) = zero!(a)
scale!{T<:BLAS.BlasFloat}(a::Array{T}, ::Zero) = zero!(a)
scale!{T<:BLAS.BlasFloat}(::Zero, a::Array{T}) = zero!(a)
scale!{T<:BLAS.BlasComplex}(a::Array{T}, ::Zero) = zero!(a)
scale!{T<:BLAS.BlasComplex}(::Zero, a::Array{T}) = zero!(a)
scale!{T<:BLAS.BlasComplex}(a::Array{T}, ::Complex{Zero}) = zero!(a)
scale!{T<:BLAS.BlasComplex}(::Complex{Zero}, a::Array{T}) = zero!(a)

end # module
