# This file generates the method definitions
# stored in generated.jl

# (This way makes the code easier to debug. Most of the combinations tried
# here don't result in a method definition.)

# Do everything in a module, to avoid polluting the Main namespace
module TemporaryCodegenModule

using StaticNumbers

# Constants needed by methods.jl
const Zero = StaticInteger{0}
const One = StaticInteger{1}
const MinusOne = StaticInteger{-1}

include("methods.jl")

# List of the numbers and the names of the associated Static
d = Dict((-1 => :MinusOne, 0 => :Zero, 1 => :One))

# List of functions that take one argument
f1 = (+, -, real, imag, log, exp, sin, cos, tan, sinpi, cospi, sign,)

# List of functions that take two arguments
f2 = (+, -, *, /)

# Do the actual code generation for f1
function fun1(f1, d)
    println("# Functions with one argument")
    for f in f1, i in keys(d)
        r = nothing
        try
            r = f(i)
        catch
            #println("# $f($i) threw an exception")
        end
        if r in keys(d)
            r1 = nothing
            try
                r1 = @eval $f(static($i))
            catch
                nothing
            end
            if r1 isa Static
                @assert r1 == r
            else
                println(f, "(::", d[i], ") = ", d[r], "()")
            end
        end
    end
end
fun1(f1, d)

# Do the actual code generation for f2
function fun2(f2, d)
    println("\n# Functions with two arguments")
    for f in f2, i in keys(d), j in keys(d)
        r = nothing
        try
            r = f(i, j)
        catch
            #println("# $f($i, $j) threw and exception")
        end
        if r in keys(d)
            r1 = nothing
            try
                r1 = f(static(i), static(j))
            catch
                nothing
            end
            if r1 isa Static
                @assert r1 == r
            else
                println(f, "(::", d[i], ", ::", d[j], ") = ", d[r], "()")
            end
        end
    end
end
fun2(f2, d)

end # module
