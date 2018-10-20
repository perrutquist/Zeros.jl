__precompile__()
module Zeros

using StaticNumbers

export Zero, testzero, One, testone, MinusOne, testminusone, zero!

# Adding methods to functions in base
include("methods.jl")

# Auto-generated methods
include("generated.jl")

# These function is intentionally not type-stable.
"Convert to Zero() if zero. (Use immediately before calling a function.)"
testzero(x::Number) = x==zero(x) ? Zero() : x
"Convert to One() if one. (Use immediately before calling a function.)"
testone(x::Number) = x==one(x) ? One() : x
"Convert to MinusOne() if minus one. (Use immediately before calling a function.)"
testminusone(x::Number) = x==-one(x) ? MinusOne() : x

"Fill an array with zeros."
zero!(a::Array{T}) where T = fill!(a, Zero())

end # module
