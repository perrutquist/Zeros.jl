using Zeros
using Base.Test


# Real
Z = Zero()
@test Z === Zero()
@test Z == Z
@test Z == 0
@test sizeof(Z) == 0
@test float(Z) === 0.0
@test -Z === Z
@test +Z === Z
@test 2*Z === Z
@test 2.0*Z === Z
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

#Complex
C = Complex(Z,Z)
@test Z*im === C
@test Z+(2+3im) === 2+3im
@test (2+3im)+Z === 2+3im
@test Z-(2+3im) === -2-3im
@test (2+3im)-Z === 2+3im
@test Z*(2+3im) === C
@test Z/(2+3im) === C

# testzero()
@test testzero(3) === 3
@test testzero(3+3im) === 3+3im
@test testzero(0) === Z
@test testzero(0+0im) === C
