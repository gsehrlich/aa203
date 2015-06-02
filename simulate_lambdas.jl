require("simulate.jl")
require("test_probs.jl")

risk_λ = (Any => Any)[]

using HDF5, JLD

data_dir = "../lambda_data/lambda_data"

function monte_carlo_all_lambdas()
    for filename in readdir(data_dir)
        λ = float(filename[17:end])
        println("λ = $(λ)")
        μ = load("$(data_dir)/$(filename)")["μ"]

        risk_λ[λ] = monte_carlo_simulate(interesting_test_prob,
                                         interesting_test_x0, μ, 10)
    end

    return risk_λ
end

function noiseless_path_lambdas()
    filenames = readdir(data_dir)
    λs = [float(filename[17:end]) for filename in filenames]
    pairs = sort([zip(λs, filenames)...])
    n = length(filenames)
    for (i, (λ, filename)) in enumerate(pairs)
        println("λ = $(λ)")
        μ = load("$(data_dir)/$(filename)")["μ"]

        color = (i/n, 0, 1 - i/n)
        plot_noiseless_path(interesting_test_prob, μ,
                            interesting_test_x0, 10, color=color)
    end
end