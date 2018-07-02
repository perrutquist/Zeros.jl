__precompile__()
module Zeros

import Base: +, -, *, /, <, >, <=, >=, fma, muladd, mod, rem, modf,
     ldexp, copysign, flipsign, sign, round, floor, ceil, trunc,
     promote_rule, convert, show, significand, string
     AbstractFloat, Integer, Complex

export Zero, testzero, zero!

 "A type that stores no data, and holds the value zero."
struct Zero <: Integer
end

Zero(x::Number) = iszero(x) ? Zero() : throw(InexactError(:Zero, Zero, x))

promote_rule(::Type{Zero}, ::Type{T}) where {T<:Number} = T
promote_rule(::Type{Zero}, ::Type{Zero}) = Float64

convert(::Type{Zero}, ::Zero) = Zero()
convert(::Type{T}, ::Zero) where {T<:Number} = zero(T)
convert(::Type{Zero}, x::T) where {T<:Number} = Zero(x)

AbstractFloat(::Zero) = 0.0

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
end

+(::Zero,::Zero) = Zero()
-(::Zero,::Zero) = Zero()
*(::Zero,::Zero) = Zero()
/(::Zero, ::Zero) = throw(DivideError())

<(::Zero,::Zero) = false
<=(::Zero,::Zero) = true

ldexp(::Zero, ::Integer) = Zero()
copysign(::Zero,::Real) = Zero()
flipsign(::Zero,::Real) = Zero()
modf(::Zero) = (Zero(), Zero())

# Alerady working due to default definitions:
# ==, !=, abs, isinf, isnan, isinteger, isreal, isimag,
# signed, unsigned, float, big, complex, isodd, iseven

for op in [:(-), :sign, :round, :floor, :ceil, :trunc, :significand]
  @eval $op(::Zero) = Zero()
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
    end
end

for op in [:mod, :rem]
  @eval $op(::Zero, ::Real) = Zero()
end

# Display Zero() as `0̸` (unicode "zero with combining long solidus overlay")
# so that it looks slightly different from `0`.
show(io::IO, ::Zero) = print(io, "0̸")
string(z::Zero) = Base.print_to_string(z)

# Display Array{Zero} without printing the actual zeros.
show(io::IO, x::Array{Zero,N}) where {N} = show(io, MIME"text/plain", x)
function show(io::IO, ::MIME"text/plain", x::Array{Zero,N}) where {N}
    join(io, map(dec, size(x)), "x")
    print(io, " Array{Zero,", N, "}")
end

# This function is intentionally not type-stable.
"Convert to Zero() if zero. (Use immediately before calling a function.)"
testzero(x::Number) = x==zero(x) ? Zero() : x

"Fill an array with zeros."
zero!(a::Array{T}) where T = fill!(a, Zero())

end # module
