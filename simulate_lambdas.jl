require("simulate.jl")
require("test_probs.jl")

using HDF5, JLD

#data_dir = error("change this to point to your data")
data_dir = "lambda_data"

function monte_carlo_all_lambdas(num_samples)
    failure_rate_λ = (Any => Any)[]
    failed_paths_λ = (Any => Any)[]
    for filename in readdir(data_dir)
        λ = float(filename[17:end])
        println("λ = $(λ)")
        μ = load("$(data_dir)/$(filename)")["μ"]

        failure_rate_λ[λ], failed_paths_λ[λ] =
                    monte_carlo_simulate(interesting_test_prob,
                                         interesting_test_x0, μ, num_samples)
    end

    return failure_rate_λ, failed_paths_λ
end

function noiseless_path_lambdas(prob; start=1, step=1, stop=nothing)
    # set up figure and grid
    
    plot_bdies_etc(prob)

    filenames = readdir(data_dir)
    if stop==nothing
        stop = length(filenames)
    end
    filenames = [filenames[i] for i in start:step:stop]
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

    plot_start_goal(interesting_test_prob, interesting_test_x0, interesting_test_x_goal)

    title("Path dependence on λ")
end

noiseless_path_lambdas() = noiseless_path_lambdas(interesting_test_prob,
    step=15)

function monte_carlo_lambdas()
    monte_carlo_dir = "monte_carlo_lambda"
    filenames = readdir(monte_carlo_dir)

    #magic numbers!!!
    λs = sort([float(filename[29:end]) for filename in filenames])
    pairs = sort([zip(λs, filenames)...])
    n = length(filenames)

    failure_rates = Real[]

    for (i, (λ, filename)) in enumerate(pairs)
        println("λ = $(λ)")
        failure_rate = load("$(monte_carlo_dir)/$(filename)")["failure_rate"]
        push!(failure_rates, failure_rate)

        #color = (i/n, 0, 1 - i/n)
        #plot_noiseless_path(interesting_test_prob, μ,
        #                    interesting_test_x0, 10, color=color)
    end

    return λs, failure_rates
end
