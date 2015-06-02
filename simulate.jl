using StatsBase

require("chance_constrained_problem.jl")

function simulate_noise(prob, x)
    probs = get_probs(prob, x)
    h, w = size(probs)

    probs_flat = reshape(probs, h*w)
    indices = [[i,j] for i in 1:h, j in 1:w]
    indices_flat = reshape(indices, h*w)

    return sample(indices_flat, WeightVec(probs_flat)) 
end

function simulate(prob, x0, μ)
    N = length(μ)

    x = x0

    for k = 1:N
        x = simulate_noise(prob, μ[k][x] + x)
        if prob.grid[x...]
            return true #we failed
        end
    end

    return false
end

function monte_carlo_simulate(prob, x0, μ, num_trials)
    failures = sum([simulate(prob, x0, μ) for k in 1:num_trials])
    return failures / num_trials
end