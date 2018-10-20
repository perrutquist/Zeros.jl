# Don't modify this code directly.
# Instead, modify codegen.jl, run it, and copy its output to this file.

# Functions with one argument
-(::Zero) = Zero()
-(::MinusOne) = One()
-(::One) = MinusOne()
imag(::Zero) = Zero()
imag(::MinusOne) = Zero()
imag(::One) = Zero()
log(::One) = Zero()
exp(::Zero) = One()
sin(::Zero) = Zero()
cos(::Zero) = One()
tan(::Zero) = Zero()
sinpi(::Zero) = Zero()
sinpi(::One) = Zero()
cospi(::Zero) = One()
cospi(::MinusOne) = MinusOne()
cospi(::One) = MinusOne()
sign(::Zero) = Zero()
sign(::MinusOne) = MinusOne()
sign(::One) = One()

# Functions with two arguments
+(::Zero, ::Zero) = Zero()
+(::MinusOne, ::One) = Zero()
+(::One, ::MinusOne) = Zero()
-(::Zero, ::Zero) = Zero()
-(::Zero, ::MinusOne) = One()
-(::Zero, ::One) = MinusOne()
*(::Zero, ::Zero) = Zero()
*(::MinusOne, ::MinusOne) = One()
*(::MinusOne, ::One) = MinusOne()
*(::One, ::MinusOne) = MinusOne()
*(::One, ::One) = One()
/(::MinusOne, ::One) = MinusOne()
/(::One, ::MinusOne) = MinusOne()
