# This file generates the method definitions
# stored in generated.jl

# (This way avoids having to eval a lot of expressions as the package
# is loaded, and makes the code easier to debug.)

# Do everything in a module, to avoid polluting the Main namespace
module TemporaryCodegenModule

using StaticNumbers

include("methods.jl")

d = Dict((-1 => :MinusOne, 0 => :Zero, 1 => :One))

f1 = (+, -, real, imag, sin, cos, tan, sinpi, cospi, sign,)

f2 = (+, -, *, /)

function fun1(f1, d)
    println("# Functions with one argument")
    for f in f1, i in keys(d)
        r = nothing
        try
            r = @eval $f($i)
        catch
            println("# eval failed for $f($i)")
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

function fun2(f2, d)
    println("\n# Functions with two arguments")
    for f in f2, i in keys(d), j in keys(d)
        r = nothing
        try
            r = @eval $f($i, $j)
        catch
            println("# eval failed for $f($i, $j)")
        end
        if r in keys(d)
            r1 = nothing
            try
                r1 = @eval $f(static($i), static($j))
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
