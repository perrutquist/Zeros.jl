using Zeros
using Test
using Test: @inferred

@testset "ambiguities" begin
    ambiguities = detect_ambiguities(Base, Zeros)
    for a in ambiguities
        println(a[1], "\n", a[2], "\n")
    end
    @test length(detect_ambiguities(Zeros)) == 0
    @test length(ambiguities) <= 5
end

const Z = Zero()
const I = One()

@testset "Promotion" begin
    @test promote_type(One, Bool) === Bool
    @test promote_type(One, Int32) === Int32
    @test promote_type(One, Int64) === Int64
    @test promote_type(One, Float32) === Float32
    @test promote_type(One, Float64) === Float64
    @test promote_type(One, Complex{Bool}) === Complex{Bool}
    @test promote_type(One, Complex{Float64}) === Complex{Float64}
    @test promote_type(Zero, Bool) === Bool
    @test promote_type(Zero, Int32) === Int32
    @test promote_type(Zero, Int64) === Int64
    @test promote_type(Zero, Float32) === Float32
    @test promote_type(Zero, Float64) === Float64
    @test promote_type(Zero, Complex{Bool}) === Complex{Bool}
    @test promote_type(Zero, Complex{Float64}) === Complex{Float64}
end

@testset "Real" begin
    @test iszero(Z) === true
    @test isone(I) === true
    @test isone(Z) === false
    @test iszero(I) === false
    @test Int(Z) === 0
    @test Int(I) === 1
    @test Float64(Z) === 0.0
    @test Float64(I) === 1.0
    @test float(Z) === 0.0
    @test float(I) === 1.0
    @test Z + 1 === 1
    @test I + 1 === 2
    @test Z + I === I
    @test Z - I === -1
    @test Zero(0) === Z
    @test One(1) === I
    @test one(Z) === I
    @test one(I) === I
    @test zero(Z) === Z
    @test zero(I) === Z
    @test Z === Zero()
    @test I === One()
    @test Z == Z
    @test I == I
    @test Z == 0
    @test I == 1
    @test sizeof(Z) == 0
    @test float(Z) === 0.0
    @test float(I) === 1.0
    @test -Z === Z
    @test -I === -1
    @test +Z === Z
    @test +I === I
    @test 2*Z === Z
    @test Z*Z === Z
    @test I*I === I
    @test 2*I === 2
    @test 2/I === 2.0
    @test I*2 === 2
    @test 2.0*Z === Z
    @test 2.0*I === 2.0
    @test Z*3 === Z
    @test Z/2 === Z
    @test Z/I === Z
    @test Z-Z === Z
    @test Z+Z === Z
    @test Z*Z === Z
    @test 1-Z === 1
    @test 1.0-Z === 1.0
    @test Z-1 == -1
    @test Z+1 == 1
    @test 2+Z == 2
    @test (Z < Z) == false
    @test (Z > Z) == false
    @test Z <= Z
    @test Z >= Z
    @test Z < 3
    @test Z > -2.0
    @test ldexp(Z, 3) === Z
    @test copysign(Z, 3) === Z
    @test copysign(Z, -1) === Z
    @test flipsign(Z, -1) === Z
    @test sign(Z) === Z
    @test round(Z) === Z
    @test floor(Z) === Z
    @test ceil(Z) === Z
    @test trunc(Z) === Z
    @test significand(Z) === Z
    @test sign(I) === I
    @test round(I) === I
    @test floor(I) === I
    @test ceil(I) === I
    @test trunc(I) === I
    @test significand(I) === I
    @test !isodd(Z)
    @test iseven(Z)
    @test isodd(I)
    @test !iseven(I)
    @test string(Z) == "𝟎"
    @test string(I) == "𝟏"
    @test mod(Z, 3) === Z
    @test mod(Z, 3.0) === Z
    @test mod(I, I) == mod(1, 1)
    @test mod(I, I) === Z
    @test rem(I, I) == rem(1, 1)
    @test rem(I, I) === Z
    @test rem(Z, 3) === Z
    @test rem(Z, 3.0) === Z
    @test modf(Z) === (Z, Z)
    @test I/I === I
    @test 1.0/I === 1.0
    @test 1/I === 1.0

    @test log(I) == log(1)
    @test log(I) === Z
    @test log2(I) == log2(1)
    @test log2(I) === Z
    @test log10(I) == log10(1)
    @test log10(I) === Z
    @test log1p(Z) == log1p(0)
    @test log1p(Z) === Z
    @test exp(Z) == exp(0)
    @test exp(Z) === I
    @test exp2(Z) == exp2(0)
    @test exp2(Z) === I
    @test exp10(Z) == exp10(0)
    @test exp10(Z) === I
    @test expm1(Z) == expm1(0)
    @test expm1(Z) === Z
    @test sin(Z) == sin(0)
    @test sin(Z) === Z
    @test cos(Z) == cos(0)
    @test cos(Z) === I
    @test sincos(Z) == sincos(0)
    @test sincos(Z) === (Z, I)
    @test tan(Z) == tan(0)
    @test tan(Z) === Z
    @test asin(Z) == asin(0)
    @test asin(Z) === Z
    @test atan(Z) == atan(0)
    @test atan(Z) === Z
    @test sinpi(Z) == sinpi(0)
    @test sinpi(Z) === Z
    @test sinpi(I) == sinpi(1)
    @test sinpi(I) === Z
    @test cospi(Z) == cospi(0)
    @test cospi(Z) === I
    @test sinh(Z) == sinh(0)
    @test sinh(Z) === Z
    @test cosh(Z) == cosh(0)
    @test cosh(Z) === I
    @test tanh(Z) == tanh(0)
    @test tanh(Z) === Z
    @test sqrt(Z) == sqrt(0)
    @test sqrt(Z) === Z
    @test sqrt(I) == sqrt(1)
    @test sqrt(I) === I
    @test cbrt(Z) == cbrt(0)
    @test cbrt(Z) === Z
    @test cbrt(I) == cbrt(1)
    @test cbrt(I) === I

    @test 3.0^Z === I
    @test 3.0f0^Z === I
    @test 3^Z === I
    @test 3^Z === I
    @test Z^Z === I
    @test I^Z === I

    @test I//I isa Rational{One}
    @test I//I + I//I == 2

    @test sum(fill(I, 23)) == 23
    @inferred sum(fill(I, 23))
    @test sum(One[]) === 0
    @test sum([One()]) === 1

    @test sum(fill(Z, 23)) === Z
    @inferred sum(fill(Z, 23))
    @test sum(Zero[]) === Z
    @test sum([Zero()]) === Z

    @test prod(fill(I, 23)) == 1
    @inferred prod(fill(I, 23))
    @test prod(One[]) === I
    @test prod([One()]) === I

    @test prod(fill(Z, 23)) === false
    @inferred prod(fill(Zero(), 23))
    @test prod(Zero[]) === true
    @test prod([Zero()]) === false

    @test false + One() === 1
    @test One() + false === 1

    @test false + Zero() === false
    @test Zero() + false === false

    @test Integer(Z) === 0
    @test Integer(I) === 1

    @test AbstractFloat(Z) === 0.0
    @test AbstractFloat(I) === 1.0

    @test Zero(Z) === Z
    @test One(I) === I

    @test inv(I) === I

    @test div(3, I) === 3
    @test div(Int32(3), I) === Int32(3)

    @test Bool(Z) === false
    @test Bool(I) === true
    @test Int32(Z) === Int32(0)
    @test Int32(I) === Int32(1)
    @test Int64(Z) === 0
    @test Int64(I) === 1
    @test Float32(Z) === 0.0f0
    @test Float32(I) === 1.0f0
    @test Float64(Z) === 0.0
    @test Float64(I) === 1.0
end

# @testset "muladd" begin
#     @test fma(Z,1,Z) === Z
#     @test fma(Z,1.0,Z) === Z
#     @test muladd(Z,1,Z) === Z
#     @test muladd(Z,1.0,Z) === Z
#     @test fma(Z,1,3) === 3
#     @test fma(Z,1.0,3) === 3.0
#     @test muladd(Z,1,3) === 3
#     @test muladd(Z,1.0,3) === 3.0
#     @test fma(Z,Z,Z) === Z
#     @test muladd(Z,Z,Z) === Z
# end

@testset "Complex" begin
    @test Z*im === Z
    @test im*Z === Z
    @test real(Z) === Z
    @test imag(Z) === Z
    @test Z+(2+3im) === 2+3im
    @test (2+3im)+Z === 2+3im
    @test Z-(2+3im) === -2-3im
    @test (2+3im)-Z === 2+3im
    @test Z*(2+3im) === Z
    @test (2.0+3.0im)*Z === Z
    @test Z/(2+3im) === Z

    @test Complex(Z,Z) == Z
    @test Complex(1,Z) == 1
    @test Complex(1.0,Z) == 1.0
    @test Complex(true,Z) == true
end

@testset "testzero" begin
    @test testzero(3) === 3
    @test testzero(3+3im) === 3+3im
    @test testzero(0) === Z
    @test testzero(0+0im) === Z
end

@testset "error handling" begin
    @test_throws InexactError Zero(1)
    @test_throws InexactError convert(Zero, 0.1)
    @test_throws DivideError 1.0/Z
    @test_throws DivideError (1.0+2.0im)/Z
    @test_throws DivideError Z/Z
    @test_throws DivideError I/Z
    @test_throws DivideError inv(Z)
    @test_throws InexactError Zero(One())
    @test_throws InexactError One(Zero())
    @test_throws DivideError mod(Z, Z)
    @test_throws DivideError rem(Z, Z)
    @test_throws MethodError convert(Irrational{:π}, Zero())
    @test_throws MethodError convert(Irrational{:π}, One())
end

# Test `MyComplex` example type
include("mycomplex_example.jl")
@testset "mycomplex_example.jl" begin
    @test MyImaginary(2)*MyImaginary(3) === MyReal(-6)
end

Zeros.@pirate Base

@testset "piracy" begin
    @test +() === Z
    @test *() === I
    @test zero() === Z
    @test one() === I
    @test sum([]) == 0
    @test prod([]) == 1
    @test sin(π) == 0
    @test tan(π) == 0
end
