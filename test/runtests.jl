using Zeros
using Test

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
    @test rem(Z, 3) === Z
    @test rem(Z, 3.0) === Z
    @test modf(Z) === (Z, Z)
    @test I/I === I
    @test 1.0/I === 1.0
    @test 1/I === 1.0

    @test log(I) == log(1)
    @test exp(Z) == exp(0)
    @test sin(Z) == sin(0)
    @test cos(Z) == cos(0)
    @test tan(Z) == tan(0)
    @test asin(Z) == asin(0)
    @test atan(Z) == atan(0)
    @test sinpi(Z) == sinpi(0)
    @test sinpi(I) == sinpi(1)
    @test cospi(Z) == cospi(0)
    @test sinh(Z) == sinh(0)
    @test cosh(Z) == cosh(0)
    @test tanh(Z) == tanh(0)

    @test I//I isa Rational{One}
    @test I//I + I//I == 2
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
end

# Test `MyComplex` example type
include("mycomplex_example.jl")
@testset "mycomplex_example.jl" begin
    @test MyImaginary(2)*MyImaginary(3) === MyReal(-6)
end
