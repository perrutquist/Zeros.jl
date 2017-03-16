module Zeros

import Base: +, -, *, /, <, >, <=, >=, fma, muladd,
     ldexp, copysign, flipsign, sign, round, floor, ceil, trunc,
     promote_rule, convert, show, significand, isodd, iseven

export Zero, testzero

 "A type that stores no data, and holds the value zero."
immutable Zero <: Real
end

const complexzero = Complex(Zero(), Zero())

promote_rule{T<:Number}(::Type{Zero}, ::Type{T}) = T
promote_rule{T<:Number}(::Type{Complex{Zero}}, ::Type{T}) = T

convert(::Type{Zero}, ::Zero) = Zero()
convert{T<:Number}(::Type{T}, ::Zero) = zero(T)
convert{T<:Number}(::Type{T}, ::Complex{Zero}) = zero(T)
convert{T<:Number}(::Type{Zero}, x::T) = x==zero(T) ? Zero() : throw(InexactError)

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

<(::Zero,::Zero) = false
>(::Zero,::Zero) = false
>=(::Zero,::Zero) = true
<=(::Zero,::Zero) = true

ldexp(::Zero, ::Integer) = Zero()
copysign(::Zero,::Real) = Zero()
flipsign(::Zero,::Real) = Zero()

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
  @eval $op{T<:Real}(::Zero, ::T, x::T) = x
  @eval $op{T<:Real}(::T, ::Zero, x::T) = x
end

isodd(::Zero) = false
iseven(::Zero) = true

# Display Zero() slightly differenlty from 0, so that it can be spotted.
show(io::IO, ::Zero) = print(io, "0̸")

"Convert to Zero() if zero. (Use immediately before calling a function.)"
# This function is intentionally not type-stable.
testzero(x::Real) = x==zero(x) ? Zero() : x
testzero(x::Complex) = x==zero(x) ? Complex(Zero(),Zero()) : x

end # module
