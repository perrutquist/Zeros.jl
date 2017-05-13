using Zeros

import Base.*

# abstract type MyAbstractComplex{T<:Real} end #v0.6
abstract MyAbstractComplex{T<:Real}

immutable MyComplex{T<:Real} <: MyAbstractComplex{T}
  re::T
  im::T
end

immutable MyReal{T<:Real} <: MyAbstractComplex{T}
  re::T
  im::Zero
end

immutable MyImaginary{T<:Real} <: MyAbstractComplex{T}
  re::Zero
  im::T
end

MyReal{T<:Real}(re::T) = MyReal{T}(re, Zero())
MyImaginary{T<:Real}(im::T) = MyImaginary{T}(Zero(), im)
MyComplex(re::Real, im::Zero) = MyReal(re)
MyComplex(re::Zero, im::Real) = MyImaginary(im)
MyComplex(::Zero, ::Zero) = MyComplex{Zero}(Zero(), Zero()) # disambiguation

*(x::MyAbstractComplex, y::MyAbstractComplex) =
    MyComplex(x.re*y.re - x.im*y.im, x.re*y.im + x.im*y.re)
