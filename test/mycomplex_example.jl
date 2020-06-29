using Zeros

struct MyComplex{R,I} <: Number
  re::R
  im::I
end

MyComplex(x::Real) = MyComplex(x, Zero())
MyComplex{R,I}(x::Real) where {R,I} = MyComplex(R(x), I(Zero()))
MyComplex{R,I}(x::MyComplex) where {R,I} = MyComplex(R(x.re), I(x.im))

Base.:*(x::MyComplex, y::MyComplex) = MyComplex(x.re*y.re - x.im*y.im, x.re*y.im + x.im*y.re)
Base.:+(x::MyComplex, y::MyComplex) = MyComplex(x.re + y.re, x.im + y.im)
Base.:-(x::MyComplex, y::MyComplex) = MyComplex(x.re - y.re, x.im - y.im)

for op in (:*, :+, :-)
    @eval begin
        Base.$op(x::Real, y::MyComplex) = $op(MyComplex(x), y)
        Base.$op(x::MyComplex, y::Real) = $op(x, MyComplex(y))
    end
end

const i = MyComplex(Zero(), One())

sizeof(1i) # 8, half the size of 1im
