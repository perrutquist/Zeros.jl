module ZerosRandomExt

using Zeros

import Random

Random.rand(::Random.AbstractRNG, ::Random.SamplerType{T}) where T<:Zeros.StaticBool = T()

end
