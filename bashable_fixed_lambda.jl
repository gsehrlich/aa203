require("ono.jl")
require("test_probs.jl")

using HDF5, JLD

# command-line params:
# λ

λ = float(ARGS[1])
N = 5

function ono_dp_wrapper(prob, x0, λ; N=N)
    return ono_dp(prob, λ, N)
end

J, μ = interesting_test(ono_dp_wrapper, (λ,), N=N)

save("lambda_fixed_at_$(λ)", "μ", μ, "J", J)