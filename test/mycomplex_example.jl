using Zeros

struct MyComplex{R,I} <: Number
  re::R
  im::I
end

MyComplex(x::Real) = MyComplex(x, Zero())
MyComplex(x::Number) = MyComplex(real(x), imag(x))
MyComplex{R,I}(x::Real) where {R,I} = MyComplex(R(x), I(Zero()))
MyComplex{R,I}(x::Number) where {R,I} = MyComplex(R(real(x)), I(imag(x)))

(::Type{T})(x::MyComplex) where {T<:Real} = x.im == 0 ? T(x.re) : throw(InexactError(Symbol(T), T, x))
Base.Complex(x::MyComplex) = Complex(x.re, x.im)
Base.Complex{T}(x::MyComplex) where {T<:Real} = Complex(T(x.re), T(x.im))

Base.promote_rule(::Type{MyComplex{R,I}}, ::Type{MyComplex{S,J}}) where {R<:Real,I<:Real,S<:Real,J<:Real} =
    MyComplex{promote_type(R,S), promote_type(I,J)}
Base.promote_rule(::Type{MyComplex{R,I}}, ::Type{S}) where {R<:Real,I<:Real,S<:Real} =
    MyComplex{promote_type(R,S), promote_type(I,Zero)}
Base.promote_rule(::Type{MyComplex{R,I}}, ::Type{Complex{S}}) where {R<:Real,I<:Real,S<:Real} =
    MyComplex{promote_type(R,S), promote_type(I,S)}

# Avoid incorrect promotion
for op in (:*, :/)
    @eval begin
        Base.$op(x::Real, y::MyComplex) = $op(MyComplex(x), y)
        Base.$op(x::MyComplex, y::Real) = $op(x, MyComplex(y))
    end
end

Base.real(x::MyComplex) = x.re
Base.imag(x::MyComplex) = x.im
Base.conj(x::MyComplex) = MyComplex(x.re, -x.im)
Base.adjoint(x::MyComplex) = conj(x)
Base.abs(x::MyComplex) = hypot(x.re, x.im)
Base.abs2(x::MyComplex) = x.re*x.re + x.im*x.im
Base.angle(x::MyComplex) = atan(z.im, z.re)
# Many more functions could be copied from base/complex.jl with no or minimal modifications

Base.:+(x::MyComplex, y::MyComplex) = MyComplex(x.re + y.re, x.im + y.im)
Base.:-(x::MyComplex, y::MyComplex) = MyComplex(x.re - y.re, x.im - y.im)
Base.:-(x::MyComplex) = MyComplex(-x.re, -x.im)

Base.:*(x::MyComplex, y::MyComplex) = MyComplex(x.re*y.re - x.im*y.im, x.re*y.im + x.im*y.re)

const MyReal = MyComplex{<:Real,Zero}
const MyImag = MyComplex{Zero,<:Real}
const MyZero = MyComplex{Zero,Zero}

Base.:/(x::MyComplex, y::MyReal) = MyComplex(x.re/y.re, x.im/y.re)
Base.:/(x::MyComplex, y::MyImag) = MyComplex(x.im/y.im, -x.re/y.im)
Base.:/(x::MyComplex, y::MyZero) = throw(DivideError()) # Disambiguation
Base.:/(x::MyComplex, y::MyComplex) = (x*y')/abs2(y)

const i = MyComplex(Zero(), One())

using Test
@test sizeof(i) == 0
@test sizeof(im) == 2
@test sizeof(1*i) == sizeof(1*im)/2
@test i*i isa MyReal
@test 1/i isa MyImag
@test abs(-7i) === 7
@test abs(-7im) === 7.0
