using Zeros
using Test

# Real
Z = Zero()
@test Zero(0) === Z
@test Z === Zero()
@test Z == Z
@test Z == 0
@test sizeof(Z) == 0
@test float(Z) === 0.0
@test -Z === Z
@test +Z === Z
@test 2*Z === Z
@test 2.0*Z === Z
@test Z*3 === Z
@test Z/2 === Z
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
@test !isodd(Z)
@test iseven(Z)
@test string(Z) == "0̸"
@test fma(Z,1,Z) === Z
@test muladd(Z,1,Z) === Z
@test fma(Z,1,3) === 3
@test muladd(Z,1,3) === 3
@test fma(Z,Z,Z) === Z
@test muladd(Z,Z,Z) === Z
@test mod(Z, 3) === Z
@test rem(Z, 3) === Z
@test modf(Z) === (Z, Z)

#Complex
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

# testzero()
@test testzero(3) === 3
@test testzero(3+3im) === 3+3im
@test testzero(0) === Z
@test testzero(0+0im) === Z

# Array functions
for cf in [(T)->T, (T)->Complex{T}]
    for T in [UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128, BigInt, Float16, Float32, Float64, BigFloat]
        A = ones(cf(T),10)
        @test zero!(A) === A
        @test all(A .== zero(cf(T)))
    end
end

# Test error handling
@test_throws InexactError Zero(1)
@test_throws InexactError convert(Zero, 0.1)
@test_throws DivideError 1.0/Z
@test_throws DivideError (1.0+2.0im)/Z
@test_throws DivideError Z/Z

# Test `MyComplex` example type
include("mycomplex_example.jl")
@test MyImaginary(2)*MyImaginary(3) === MyReal(-6)
