module Zeros

export Zero, testzero, One, testone

 "A type that stores no data, and holds the value zero."
struct Zero <: Integer
end

"A type that stores no data, and holds the value one."
struct One <: Integer
end

const StaticBool = Union{Zero, One}

Base.promote_rule(::Type{One}, ::Type{T}) where {T<:Number} = T
Base.promote_rule(::Type{Zero}, ::Type{T}) where {T<:Number} = T

# For some reason the promote-rules involving StaticBool and Bool need to be
# defined in both directions, or we get stack overflow.
for S in (Zero, One, Bool), T in (Zero, One, Bool)
    if S ≠ T
        Base.promote_rule(::Type{S}, ::Type{T}) = Bool
    end
end

Base.convert(::Type{T}, ::Zero) where {T<:Number} = T(zero(T))
Base.convert(::Type{T}, ::One) where {T<:Number} = oneunit(T)
Base.convert(::Type{Zero}, ::One) = throw(InexactError(:Zero, Zero, One()))
Base.convert(::Type{One}, ::Zero) = throw(InexactError(:One, One, Zero()))

# Some of the more common constructors that do not default to `convert`
# Note:  We cannot have a (::Type{T})(x::StaticBool) where {T<:Number} constructor
# instead of all of these, because of ambiguities with user-defined types.
for T in (:Bool, :Integer, :AbstractFloat,
          :BigInt, :Int128, :Int16, :Int32, :Int64, :Int8,
          :UInt128, :UInt16, :UInt32, :UInt64, :UInt8,
          :BigFloat, :Float16, :Float32, :Float64)
    @eval Base.$T(::Zero) = zero($T)
    @eval Base.$T(::One) = one($T)
end

#disambig
Zero(x::Number) = iszero(x) ? Zero() : throw(InexactError(:Zero, Zero, x))
One(x::Number) = isone(x) ? One() : throw(InexactError(:One, One, x))

# disambig
Zero(::Zero) = Zero()
One(::One) = One()
Zero(::One) = throw(InexactError(:Zero, Zero, One()))
One(::Zero) = throw(InexactError(:One, One, Zero()))

Base.zero(::StaticBool) = Zero()
Base.zero(::Type{<:StaticBool}) = Zero()
Base.one(::StaticBool) = One()
Base.one(::Type{<:StaticBool}) = One()

Base.Complex(x::Real, ::Zero) = x

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

Base.inv(::One) = One()
Base.inv(::Zero) = throw(DivideError())

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
            @eval Base.$op(::$T1, ::$T2) = $val
        end
    end
end

Base.:+(::One, x::Bool) = 1 + x
Base.:+(x::Bool, ::One) = x + 1

Base.:-(::Zero) = Zero()
Base.:-(::One) = -1

Base.:/(::Zero, ::Zero) = throw(DivideError())
Base.:/(::One, ::One) = One()

# Disambig
Base.:/(::One, ::Zero) = throw(DivideError())
Base.:/(::Zero, ::One) = Zero()

Base.:<(::T,::T) where {T<:StaticBool} = false
Base.:<=(::T,::T) where {T<:StaticBool} = true

Base.ldexp(::Zero, ::Integer) = Zero()
Base.copysign(::Zero,::Real) = Zero()
Base.flipsign(::Zero,::Real) = Zero()
Base.modf(::Zero) = (Zero(), Zero())

# Alerady working due to default definitions:
# ==, !=, abs, isinf, isnan, isinteger, isreal, isimag,
# signed, unsigned, float, big, complex, isodd, iseven

for op in [:sign, :round, :floor, :ceil, :trunc, :significand]
    @eval Base.$op(::Zero) = Zero()
    @eval Base.$op(::One) = One()
end

Base.log(::One) = Zero()
Base.log10(::One) = Zero()
Base.log2(::One) = Zero()
Base.log1p(::Zero) = Zero()
Base.exp(::Zero) = One()
Base.exp2(::Zero) = One()
Base.exp10(::Zero) = One()
Base.expm1(::Zero) = Zero()
Base.sin(::Zero) = Zero()
Base.cos(::Zero) = One()
Base.sincos(::Zero) = (Zero(), One())
Base.tan(::Zero) = Zero()
Base.asin(::Zero) = Zero()
Base.atan(::Zero) = Zero()
Base.sinpi(::Zero) = Zero()
Base.sinpi(::One) = Zero()
Base.cospi(::Zero) = One()
Base.sinh(::Zero) = Zero()
Base.cosh(::Zero) = One()
Base.tanh(::Zero) = Zero()
Base.sqrt(::One) = One()
Base.sqrt(::Zero) = Zero()
Base.cbrt(::One) = One()
Base.cbrt(::Zero) = Zero()
Base.hypot(::Zero, x::Number) = abs(x)
Base.hypot(x::Number, ::Zero) = abs(x)

# ^ has a lot of very specific methods in Base....
for T in (Float16, Float32, Float64, BigFloat, AbstractFloat, Rational, Complex{<:AbstractFloat}, Complex{<:Integer}, Integer, BigInt)
    Base.:^(::T, ::Zero) = One()
end

Base.to_power_type(::Zero) = false

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
  @eval Base.$op(::Zero, ::$T) = Zero()
end
Base.mod(::Zero, ::Zero) = throw(DivideError()) # disambig
Base.rem(::Zero, ::Zero) = throw(DivideError()) #
Base.mod(::One, ::One) = Zero()
Base.rem(::One, ::One) = Zero()

# Sum up vector of One() to Int
Base.reduce_empty(::typeof(Base.add_sum), ::Type{One}) = zero(Int)
Base.reduce_first(::typeof(Base.add_sum), x::One) = Int(x)

# Sum up arrays of Zero() to Zero()
Base.add_sum(::Zero, ::Zero) = Zero()

# Product of vector of Zero() to Bool
Base.reduce_empty(::typeof(Base.mul_prod), ::Type{Zero}) = true
Base.reduce_first(::typeof(Base.mul_prod), ::Zero) = false

# Product of vector of One() to One()
Base.reduce_empty(::typeof(Base.mul_prod), ::Type{One}) = One()

# Multiply up arrays of One() to One()
Base.mul_prod(::One, ::One) = One()

# Multiply up arrays of Zero() to `false` (when length is nonzero)
Base.mul_prod(::Zero, x::Zero) = false
Base.mul_prod(::Zero, x::Bool) = false
Base.mul_prod(::Bool, x::Zero) = false

# Display Zero() as `𝟎` ("mathematical bold digit zero")
# so that it looks slightly different from `0` (and same for One()).
Base.show(io::IO, ::Zero) = print(io, "𝟎") # U+1D7CE
Base.show(io::IO, ::One) = print(io, "𝟏") # U+1D7CF

Base.string(z::StaticBool) = Base.print_to_string(z)

Base.Checked.checked_abs(x::StaticBool) = x
Base.Checked.checked_mul(x::StaticBool, y::StaticBool) = x*y
Base.Checked.mul_with_overflow(x::StaticBool, y::StaticBool) = (x*y, false)
Base.Checked.checked_add(x::StaticBool, y::StaticBool) = x+y

if VERSION < v"1.2"
    # Disambiguation needed for older Julia versions
    Base.copysign(::Zero, x::Unsigned) = Zero()
    Base.flipsign(::Zero, x::Unsigned) = Zero()
end

include("pirate.jl")

end # module
