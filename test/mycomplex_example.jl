using Zeros

abstract type MyAbstractComplex{T<:Real} end

struct MyComplex{T<:Real} <: MyAbstractComplex{T}
  re::T
  im::T
end

struct MyReal{T<:Real} <: MyAbstractComplex{T}
  re::T
  im::Zero
end

struct MyImaginary{T<:Real} <: MyAbstractComplex{T}
  re::Zero
  im::T
end

MyReal(re::T) where {T<:Real} = MyReal{T}(re, Zero())
MyImaginary(im::T) where {T<:Real} = MyImaginary{T}(Zero(), im)
MyComplex(re::Real, im::Zero) = MyReal(re)
MyComplex(re::Zero, im::Real) = MyImaginary(im)
MyComplex(::Zero, ::Zero) = MyComplex{Zero}(Zero(), Zero()) # disambiguation

Base.:*(x::MyAbstractComplex, y::MyAbstractComplex) =
    MyComplex(x.re*y.re - x.im*y.im, x.re*y.im + x.im*y.re)
