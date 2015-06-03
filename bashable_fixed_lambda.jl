require("ono.jl")
require("test_probs.jl")

using HDF5, JLD

# command-line params:
# λ

λ = float(ARGS[1])
N = 50

function ono_dp_wrapper(prob, x0, λ; N=N)
    return ono_dp(prob, λ, N)
end

J, μ = interesting_test(ono_dp_wrapper, (λ,), N=N, to_return=(:J, :μ))

#save("lambda_fixed_at_$(λ)", "μ", μ, "J", J)
failure_rate, failed_paths = monte_carlo_simulate(interesting_test_prob,
                                                    interesting_test_x0, 
                                                    μ, 
                                                    10000)
save("monte_carlo_lambda_fixed_at_$(λ)", "failure_rate", failure_rate, "failed_paths", failed_paths)
