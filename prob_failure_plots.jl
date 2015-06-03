require("simulate_lambdas.jl")
require("test_probs.jl")

using PyPlot

function prob_failure_plot()
    λs, failure_rates = monte_carlo_lambdas()

    filenames = readdir("lambda_data")
    λs = [float(filename[17:end]) for filename in filenames]
    pairs = sort([zip(λs, filenames)...])

    risk_to_gos = Real[]

    n = length(filenames)
    for (i, (λ, filename)) in enumerate(pairs)
        println("λ = $(λ)")
        μ = load("$(data_dir)/$(filename)")["μ"]

        r = risk_to_go(interesting_test_prob, 50, μ)
        push!(risk_to_gos, r[interesting_test_x0...])
    end

    return sort(λs), failure_rates, risk_to_gos
end

function make_plot(λs, failure_rates, risk_to_gos)
    figure()
    semilogx(λs, failure_rates, λs, risk_to_gos)
    xlabel("λ")
    ylabel("prob. of failure")
    legend(["Empirical (10000 trials)", "Risk-to-go"])
    title("Prob. of failure versus dual variable λ")
    savefig("prob_failure_vs_lambda.png", format="png", dpi=1000)
end
