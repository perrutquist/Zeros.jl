module Zeros

import Base: +, -, *, /, <, >, <=, >=, fma, muladd, mod, rem, modf,
     ldexp, copysign, flipsign, sign, round, floor, ceil, trunc,
     promote_rule, convert, show, significand, isodd, iseven, scale!

export Zero, testzero, zero!

 "A type that stores no data, and holds the value zero."
immutable Zero <: Real
end

promote_rule{T<:Number}(::Type{Zero}, ::Type{T}) = T

convert(::Type{Zero}, ::Zero) = Zero()
convert{T<:Number}(::Type{T}, ::Zero) = zero(T)
convert{T<:Number}(::Type{Zero}, x::T) = x==zero(T) ? Zero() : throw(InexactError())

const CZero = Complex{Zero}
const RCZero = Union{Zero, CZero}

const complexzero = CZero(Zero(), Zero())

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

/(::Zero, ::Real) = Zero()
/(::RCZero, ::Complex) = complexzero
/(::Real, ::RCZero) = throw(DivideError())
/(::Complex, ::RCZero) = throw(DivideError())
for T1 in [Zero, CZero]
  for T2 in [Zero, CZero]
    @eval /(::$T1, ::$T2) = throw(DivideError())
  end
end

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
    :( zero!(reinterpret(T,a)); return a ) # Faster on jula 0.6.0-rc1
  else
    :( fill!(a, complexzero); return a ) # default method
  end
end

# Map scale! to zero! because some impelmentations convert the argument early.
scale!{T<:Real}(a::Array{T}, ::RCZero) = zero!(a)
scale!{T<:Real}(::RCZero, a::Array{T}) = zero!(a)
scale!{T<:BLAS.BlasFloat}(a::Array{T}, ::RCZero) = zero!(a)
scale!{T<:BLAS.BlasFloat}(::RCZero, a::Array{T}) = zero!(a)
scale!{T<:BLAS.BlasComplex}(a::Array{T}, ::RCZero) = zero!(a)
scale!{T<:BLAS.BlasComplex}(::RCZero, a::Array{T}) = zero!(a)

end # module
