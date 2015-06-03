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

    x = Array{Int32, 1}[]
    push!(x, x0)

    for k = 1:N
        push!(x, simulate_noise(prob, μ[k][x[k]] + x[k]))
        if prob.grid[x[k+1]...]
            return true, x #we failed
        end
    end

    return false, x
end

function monte_carlo_simulate(prob, x0, μ, num_trials)
    simulations = [simulate(prob, x0, μ) for k in 1:num_trials]
    failures = sum([zip(simulations...)...][1])
    failure_rate = failures/num_trials

    failed_paths = Array{Array{Int32, 1}, 1}[]
    for (failed, path) in simulations
        if failed
            push!(failed_paths, path)
        end
    end
    
    return failure_rate, failed_paths
end