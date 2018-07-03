__precompile__()
module Zeros

import Base: +, -, *, /, <, >, <=, >=, &, |, xor,
     fma, muladd, mod, rem, modf,
     ldexp, copysign, flipsign, sign, round, floor, ceil, trunc,
     promote_rule, convert, show, significand, string,
     AbstractFloat, Integer, Complex

export Zero, testzero, zero!, One, testone

"A type that stores no data, and holds the value zero."
struct Zero <: Integer
end

"A type that stores no data, and holds the value one."
struct One <: Integer
end

const TypeBool = Union{Zero, One}

if VERSION < v"0.7-"
    isone(x) = x==1
    Zero(x::Number) = x==0 ? Zero() : throw(InexactError())
    One(x::Number) = x==1 ? One() : throw(InexactError())
    convert(::Type{<:TypeBool}, x::TypeBool) = throw(InexactError())

    # Disambiguation needed for Julia 0.6
    convert(::Type{T}, ::Zero) where {T<:Real} = zero(T)
    convert(::Type{BigInt}, ::Zero) = zero(BigInt)
    convert(::Type{BigFloat}, ::Zero) = zero(BigFloat)
    convert(::Type{Float16}, ::Zero) = zero(Float16)
    convert(::Type{Complex{T}}, ::Zero) where {T<:Real} = zero(Complex{T})
    convert(::Type{Complex{T}}, ::One) where {T<:Real} = one(Complex{T})
    convert(::Type{Bool}, ::Zero) = false
    convert(::Type{Bool}, ::One) = true
else
    Zero(x::Number) = iszero(x) ? Zero() : throw(InexactError(:Zero, Zero, x))
    One(x::Number) = isone(x) ? One() : throw(InexactError(:One, One, x))
    convert(::Type{T}, x::TypeBool) where {T<:TypeBool} = throw(InexactError(:convert, T, x))
    Base.isone(::Zero) = false
end

Base.iszero(::One) = false

promote_rule(::Type{T}, ::Type{<:TypeBool}) where {T<:Number} = T
promote_rule(::Type{T}, ::Type{<:TypeBool}) where {T<:Real} = T
promote_rule(::Type{Complex{T}}, ::Type{<:TypeBool}) where {T<:Real} = Complex{T}
promote_rule(::Type{Bool}, ::Type{<:TypeBool}) = Bool
promote_rule(::Type{<:TypeBool}, ::Type{<:TypeBool}) = Bool

convert(::Type{Zero}, ::Zero) = Zero()
convert(::Type{One}, ::One) = One()

convert(::Type{T}, ::Zero) where {T<:Number} = zero(T)
convert(::Type{T}, ::One) where {T<:Number} = one(T)

convert(::Type{B}, x::T) where {B<:TypeBool, T<:Number} = B(x)

AbstractFloat(::Zero) = 0.0
AbstractFloat(::One) = 1.0

Complex(x::Real, ::Zero) = x

# Loop over types in order to make methods specific enough to avoid ambiguities.
for T in (Number, Real, Integer, Complex, Complex{Bool})
    Base.:+(x::T,::Zero) = x
    Base.:+(::Zero,x::T) = x
    Base.:-(x::T,::Zero) = x
    Base.:-(::Zero,x::T) = -x
    Base.:*(::T,::Zero) = Zero()
    Base.:*(::Zero,::T) = Zero()
    Base.:/(::Zero, ::T) = Zero()
    Base.:/(::T, ::Zero) = throw(DivideError())
    Base.:*(x::T,::One) = x
    Base.:*(::One, x::T) = x
    Base.:/(x::T, ::One) = x
    #Base.:/(x::One, ::T) = inv(x)
end

#+(::Zero,::Zero) = Zero()
-(::Zero) = Zero()
#-(::Zero,::Zero) = Zero()
#*(::Zero,::Zero) = Zero()
/(::Zero, ::Zero) = throw(DivideError())
-(::One) = -1
#-(::One, ::One) = Zero()
#*(::One, ::One) = One()
/(::One, ::One) = One()

# disambiguation
#*(::Zero, ::One) = Zero()
#*(::One, ::Zero) = Zero()
/(::Zero, ::One) = Zero()
/(::One, ::Zero) = throw(DivideError())

<(::T,::T) where {T<:TypeBool} = false
<=(::T,::T) where {T<:TypeBool} = true

# These functions are intentionally not type-stable.
"Convert to Zero() if equal to zero. (Use immediately before calling a function.)"
testzero(x::Number) = iszero(x) ? Zero() : x
"Convert to One() if equal to one. (Use immediately before calling a function.)"
testone(x::Number) = isone(x) ? One() : x

# This functions give a strange "of_sametype" error. (See int.jl)
# Hence we overload all, even when result is not One() or Zero()
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

ldexp(::Zero, ::Integer) = Zero()
copysign(::Zero,::Real) = Zero()
flipsign(::Zero,::Real) = Zero()
modf(::Zero) = (Zero(), Zero())
modf(::One) = (Zero(), One())

# Alerady working due to default definitions:
# ==, !=, abs, isinf, isnan, isinteger, isreal, isimag,
# signed, unsigned, float, big, complex, isodd, iseven

for op in [:sign, :round, :floor, :ceil, :trunc, :significand]
    @eval $op(::Zero) = Zero()
    @eval $op(::One) = One()
end

# Avoid promotion of triplets
for op in [:fma :muladd]
    @eval $op(::Zero, ::Zero, ::Zero) = Zero()
    for T in (Real, Integer)
        @eval $op(::Zero, ::$T, ::Zero) = Zero()
        @eval $op(::$T, ::Zero, ::Zero) = Zero()
        @eval $op(::Zero, x::$T, y::$T) = convert(promote_type(typeof(x),typeof(y)),y)
        @eval $op(x::$T, ::Zero, y::$T) = convert(promote_type(typeof(x),typeof(y)),y)
        @eval $op(x::$T, y::$T, ::Zero) = x*y
        @eval $op(::One, x::$T, y::$T) = x+y
        @eval $op(x::$T, ::One, y::$T) = x+y
    end
end

for op in [:mod, :rem]
  @eval $op(::Zero, ::Real) = Zero()
end

# Display Zero() as `𝟎` ("mathematical bold digit zero")
# so that it looks slightly different from `0` (and same for One()).
show(io::IO, ::Zero) = print(io, "𝟎") # U+1D7CE
show(io::IO, ::One) = print(io, "𝟏") # U+1D7CF

string(z::TypeBool) = Base.print_to_string(z)

# Display Array{Zero} without printing the actual zeros.
show(io::IO, x::Array{Zero,N}) where {N} = show(io, MIME"text/plain", x)
function show(io::IO, ::MIME"text/plain", x::Array{Zero,N}) where {N}
    join(io, map(dec, size(x)), "x")
    print(io, " Array{Zero,", N, "}")
end

"Fill an array with zeros."
zero!(a::Array{T}) where T = fill!(a, Zero())

end # module
