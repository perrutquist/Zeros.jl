# This file generates the method definitions
# stored in generated.jl

# (This way avoids having to eval a lot of expressions as the package
# is loaded, and makes the code easier to debug.)

# Do everything in a module, to avoid polluting the Main namespace
module TemporaryCodegenModule

using StaticNumbers

d = Dict((-1 => :MinusOne, 0 => :Zero, 1 => :One))

f1 = (+, -, real, imag, sin, cos, tan, sinpi, cospi, sign,)

f2 = (+, -, *, /)

println("# Functions with one argument")
for f in f1, i in keys(d)
    try
        r = @eval $f($i)
        if r in keys(d)
            r1 = @eval $f(static($i))
            if r1 isa Static
                @assert r1 == r
            else
                println(f, "(::", d[i], ") = ", d[r], "()")
            end
        end
    catch
        println("# eval failed for $f($i)")
    end
end

println("\n# Functions with two arguments")
for f in f2, i in keys(d), j in keys(d)
    try
        r = @eval $f($i, $j)
        if r in keys(d)
            r1 = @eval $f(static($i), static($j))
            if r1 isa Static
                @assert r1 == r
            else
                println(f, "(::", d[i], ", ::", d[j], ") = ", d[r], "()")
            end
        end
    catch
        println("# eval failed for $f($i, $j)")
    end
end

end
