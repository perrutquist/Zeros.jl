module Zeros

import Base: +, -, *, /, <, >, <=, >=, &, |, xor,
     fma, muladd, mod, rem, modf, one, zero, div,
     ldexp, copysign, flipsign, sign, round, floor, ceil, trunc,
     promote_rule, convert, show, significand, string,
     AbstractFloat, Integer, Complex

export Zero, testzero, One, testone

 "A type that stores no data, and holds the value zero."
struct Zero <: Integer
end

"A type that stores no data, and holds the value one."
struct One <: Integer
end

const StaticBool = Union{Zero, One}

promote_rule(::Type{<:StaticBool}, ::Type{T}) where {T<:Number} = T
promote_rule(::Type{<:StaticBool}, ::Type{T}) where {T<:Real} = T
promote_rule(::Type{<:StaticBool}, ::Type{Complex{T}}) where {T<:Real} = Complex{T}
promote_rule(::Type{<:StaticBool}, ::Type{Bool}) = Bool
promote_rule(::Type{<:StaticBool}, ::Type{<:StaticBool}) = Bool

convert(::Type{T}, ::Zero) where {T<:Number} = zero(T)
convert(::Type{T}, ::One) where {T<:Number} = one(T)

# Why are these needed ???
(::Type{T})(::Zero) where {T<:Number} = zero(T)
(::Type{T})(::One) where {T<:Number} = one(T)

Zero(x::Number) = iszero(x) ? Zero() : throw(InexactError(:Zero, Zero, x))
One(x::Number) = isone(x) ? One() : throw(InexactError(:One, One, x))

# disambig
Zero(::Zero) = Zero()
One(::One) = One()

AbstractFloat(::Zero) = 0.0
AbstractFloat(::One) = 1.0

zero(::StaticBool) = Zero()
zero(::Type{<:StaticBool}) = Zero()
one(::StaticBool) = One()
one(::Type{<:StaticBool}) = One()

Complex(x::Real, ::Zero) = x

# Loop over types in order to make methods specific enough to avoid ambiguities.
for T in (Number, Real, Rational, Integer, Complex, Complex{Bool})
    Base.:+(x::T, ::Zero) = x
    Base.:+(::Zero, x::T) = x
    Base.:-(x::T, ::Zero) = x
    Base.:-(::Zero, x::T) = -x
    Base.:*(::T, ::Zero) = Zero()
    Base.:*(::Zero, ::T) = Zero()
    Base.:/(::Zero, ::T) = Zero()
    Base.:/(::T, ::Zero) = throw(DivideError())
    Base.:*(x::T, ::One) = x
    Base.:*(::One, x::T) = x
end

# Division sometimes returns a different type from the arguments, e.g. for Int/Int.
Base.:/(x::AbstractFloat, ::One) = x

# Loop over rounding modes in order to make methods specific enough to avoid ambiguities.
for R in (RoundingMode, RoundingMode{:Down}, RoundingMode{:Up}, Union{RoundingMode{:Nearest}, RoundingMode{:NearestTiesAway}, RoundingMode{:NearestTiesUp}})
    Base.div(x::Integer, ::One, ::R) = x
end

# These functions are intentionally not type-stable.
"Convert to Zero() if equal to zero. (Use immediately before calling a function.)"
testzero(x::Number) = iszero(x) ? Zero() : x
"Convert to One() if equal to one. (Use immediately before calling a function.)"
testone(x::Number) = isone(x) ? One() : x

# This functions give a strange "of_sametype" error. (See int.jl)
# Hence we overload them all, even when result is not One() or Zero()
for op in (:+, :-, :*, :&, :|, :xor)
    for (T1,x) in ((:Zero, 0), (:One, 1))
        for (T2,y) in ((:Zero, 0), (:One, 1))
            val = @eval($op($x,$y))
            val = testzero(val)
            val = testone(val)
            @eval $op(::$T1, ::$T2) = $val
        end
    end
end

-(::Zero) = Zero()
-(::One) = -1

/(::Zero, ::Zero) = throw(DivideError())
/(::One, ::One) = One()

# Disambig
/(::One, ::Zero) = throw(DivideError())
/(::Zero, ::One) = Zero()

<(::T,::T) where {T<:StaticBool} = false
<=(::T,::T) where {T<:StaticBool} = true

ldexp(::Zero, ::Integer) = Zero()
copysign(::Zero,::Real) = Zero()
flipsign(::Zero,::Real) = Zero()
modf(::Zero) = (Zero(), Zero())

# Alerady working due to default definitions:
# ==, !=, abs, isinf, isnan, isinteger, isreal, isimag,
# signed, unsigned, float, big, complex, isodd, iseven

for op in [:sign, :round, :floor, :ceil, :trunc, :significand]
    @eval $op(::Zero) = Zero()
    @eval $op(::One) = One()
end

log(::One) = Zero()
exp(::Zero) = One()
sin(::Zero) = Zero()
cos(::Zero) = One()
tan(::Zero) = Zero()
asin(::Zero) = Zero()
atan(::Zero) = Zero()
sinpi(::Zero) = Zero()
sinpi(::One) = Zero()
cospi(::Zero) = One()
sinh(::Zero) = Zero()
cosh(::Zero) = One()
tanh(::Zero) = Zero()

# # Avoid promotion of triplets
# for op in [:fma :muladd]
#     @eval $op(::Zero, ::Zero, ::Zero) = Zero()
#     for T in (Real, Integer)
#         @eval $op(::Zero, ::$T, ::Zero) = Zero()
#         @eval $op(::$T, ::Zero, ::Zero) = Zero()
#         @eval $op(::Zero, x::$T, y::$T) = convert(promote_type(typeof(x),typeof(y)),y)
#         @eval $op(x::$T, ::Zero, y::$T) = convert(promote_type(typeof(x),typeof(y)),y)
#         @eval $op(x::$T, y::$T, ::Zero) = x*y
#         @eval $op(::One, x::$T, y::$T) = x+y
#         @eval $op(x::$T, ::One, y::$T) = x+y
#     end
# end

for op in [:mod, :rem], T in (:Real, :Rational)
  @eval $op(::Zero, ::$T) = Zero()
end
mod(::Zero, ::Zero) = throw(DivideError()) # disambig
rem(::Zero, ::Zero) = throw(DivideError()) #
mod(::One, ::One) = Zero()
rem(::One, ::One) = Zero()

# Display Zero() as `𝟎` ("mathematical bold digit zero")
# so that it looks slightly different from `0` (and same for One()).
show(io::IO, ::Zero) = print(io, "𝟎") # U+1D7CE
show(io::IO, ::One) = print(io, "𝟏") # U+1D7CF

string(z::StaticBool) = Base.print_to_string(z)

Base.Checked.checked_abs(x::StaticBool) = x
Base.Checked.checked_mul(x::StaticBool, y::StaticBool) = x*y
Base.Checked.mul_with_overflow(x::StaticBool, y::StaticBool) = (x*y, false)
Base.Checked.checked_add(x::StaticBool, y::StaticBool) = x+y

if VERSION < v"1.2"
    # Disambiguation needed for older Julia versions
    copysign(::Zero, x::Unsigned) = Zero()
    flipsign(::Zero, x::Unsigned) = Zero()
end

include("pirate.jl")

end # module
