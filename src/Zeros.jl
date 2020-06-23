__precompile__()
module Zeros

using StaticNumbers

export Zero, testzero, One, testone, MinusOne, testminusone, zero!

"A type that stores no data, and holds the value zero."
const Zero = StaticInteger{0}

"A type that stores no data, and holds the value one."
const One = StaticInteger{1}

"A type that stores no data, and holds the value minus one."
const MinusOne = StaticInteger{-1}

# Adding methods to functions in base
include("methods.jl")

# Auto-generated methods
include("generated.jl")

# These functions are intentionally not type-stable.
"Convert to Zero() if zero. (Use immediately before calling a function.)"
testzero(x::Number) = x==zero(x) ? Zero() : x
"Convert to One() if one. (Use immediately before calling a function.)"
testone(x::Number) = x==one(x) ? One() : x
"Convert to MinusOne() if minus one. (Use immediately before calling a function.)"
testminusone(x::Number) = x==-one(x) ? MinusOne() : x

"Fill an array with zeros."
zero!(a::Array{T}) where T = fill!(a, Zero())

end # module
