module ZerosSIMDExt

using Zeros, SIMD
using Zeros: StaticBool

Base.:+(v::Vec, ::Zero) = v
Base.:+(::Zero, v::Vec) = v

Base.:+(v::Vec, ::One) = v + one(v)
Base.:+(::One, v::Vec) = v + one(v)

Base.:-(v::Vec, ::Zero) = v
Base.:-(::Zero, v::Vec) = -v

Base.:-(v::Vec, ::One) = v - one(v)
Base.:-(::One, v::Vec) = one(v) - v

Base.:*(v::Vec, ::One) = v
Base.:*(::One, v::Vec) = v

Base.:*(::Zero, ::Vec) = Zero()
Base.:*(::Vec, ::Zero) = Zero()

const BINARY_OPS = [
    :(Base.div)
    :(Base.rem)
    :(Base.:^)
    :(Base.:/)
    :(Base.min)
    :(Base.max)
    :(Base.:(==))
    :(Base.:!=)
    :(Base.:>)
    :(Base.:>=)
    :(Base.:<)
    :(Base.:<=)
]

for op in BINARY_OPS
    @eval begin
        $op(v::T, ::Zero) where {T <: Vec} = $op(v, zero(T))
        $op(::Zero, v::T) where {T <: Vec} = $op(zero(T), v)
        $op(v::T, ::One) where {T <: Vec} = $op(v, one(T))
        $op(::One, v::T) where {T <: Vec} = $op(one(T), v)
    end
end

for op in [:fma :muladd]
    @eval Base.$op(a::Vec,b::StaticBool,c::StaticBool) = a * b + c
    @eval Base.$op(a::StaticBool,b::Vec,c::StaticBool) = a * b + c
    @eval Base.$op(a::StaticBool,b::StaticBool,c::Vec) = a * b + c
    @eval Base.$op(a::Vec,b::Vec,c::StaticBool) = a * b + c
    @eval Base.$op(a::Vec,b::StaticBool,c::Vec) = a * b + c
    @eval Base.$op(a::StaticBool,b::Vec,c::Vec) = a * b + c
end

end
