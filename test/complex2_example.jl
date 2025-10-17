using Zeros

struct Complex2{R,I} <: Number
  re::R
  im::I
end

Complex2(::Zero, ::Zero) = Zero()

Complex2(x::Real) = Complex2(x, Zero())
Complex2(x::Number) = Complex2(real(x), imag(x))
Complex2{R,I}(x::Number) where {R,I} = Complex2(R(real(x)), I(imag(x)))

Base.Complex(x::Complex2) = Complex(x.re, x.im)

Base.convert(::Type{T}, x::Complex2) where {T<:Real} = x.im == 0 ? T(x.re) : throw(InexactError(Symbol(T), T, x))
Base.convert(::Type{Complex{T}}, x::Complex2) where {T<:Real} = Complex(T(x.re), T(x.im))

Base.promote_rule(::Type{Complex2{R,I}}, ::Type{Complex2{S,J}}) where {R<:Real,I<:Real,S<:Real,J<:Real} =
    Complex2{promote_type(R,S), promote_type(I,J)}
Base.promote_rule(::Type{Complex2{R,I}}, ::Type{S}) where {R<:Real,I<:Real,S<:Real} =
    Complex2{promote_type(R,S), promote_type(I,Zero)}
Base.promote_rule(::Type{Complex2{R,I}}, ::Type{Complex{S}}) where {R<:Real,I<:Real,S<:Real} =
    Complex2{promote_type(R,S), promote_type(I,S)}

# Avoid unnecessary/incorrect promotion
for op in (:+, :-, :*, :/)
    @eval begin
        Base.$op(x::Real, y::Complex2) = $op(Complex2(x, Zero()), y)
        Base.$op(x::Complex2, y::Real) = $op(x, Complex2(y, Zero()))
    end
end

Base.real(x::Complex2) = x.re
Base.imag(x::Complex2) = x.im
Base.conj(x::Complex2) = Complex2(x.re, -x.im)
Base.adjoint(x::Complex2) = conj(x)
Base.abs(x::Complex2) = hypot(x.re, x.im)
Base.abs2(x::Complex2) = x.re*x.re + x.im*x.im
Base.angle(x::Complex2) = atan(z.im, z.re)
# Many more functions could be copied from base/complex.jl with no or minimal modifications

Base.:+(x::Complex2, y::Complex2) = Complex2(x.re + y.re, x.im + y.im)
Base.:-(x::Complex2, y::Complex2) = Complex2(x.re - y.re, x.im - y.im)
Base.:-(x::Complex2) = Complex2(-x.re, -x.im)

Base.:*(x::Complex2, y::Complex2) = Complex2(x.re*y.re - x.im*y.im, x.re*y.im + x.im*y.re)

const MyReal = Complex2{<:Real,Zero}
const Imag2 = Complex2{Zero,<:Real}

Base.:/(x::Complex2, y::MyReal) = Complex2(x.re/y.re, x.im/y.re)
Base.:/(x::Complex2, y::Imag2) = Complex2(x.im/y.im, -x.re/y.im)
Base.:/(x::Complex2, y::Complex2) = (x*y')/abs2(y)

const i = Complex2(Zero(), One())

using Test
@test sizeof(i) == 0
@test sizeof(im) == 2
@test sizeof(1*i) == sizeof(1*im)/2
@test i*i isa MyReal
@test 1/i isa Imag2
@test abs(-7i) === 7
@test abs(-7im) === 7.0

#using BenchmarkTools
#f(x,y) = x + y*im
#g(x,y) = x + y*i
#a = one(BigFloat)
#b = one(BigFloat)
#@btime f($a, $b)
#@btime g($a, $b)
