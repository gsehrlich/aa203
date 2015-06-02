# easy_test: Look for obvious mistakes
require("ono.jl");

function easy_test(alg, x0=nothing, plot=false, N=nothing,
                   alg_args=(); alg_kwargs=(Any => Any)[])
    grid = [0 0; 0 0]
    g_N(x) = x == [2, 2]? 0 : 1
    g_k(k, x, u) = norm(u)
    Δ = 0.1
    σ² = 1
    d = 1.5 # 1-diagonals ok but not 2 in a row
    easy_test_prob = ChanceConstrainedProblem(grid, g_N, g_k, Δ, σ², d)

    if x0 == nothing
        x0 = [1, 1]
    end
    if N == nothing
        N = 5
    end
    μ = alg(easy_test_prob, x0, alg_args...; N=5, alg_kwargs...)

    if plot
        plot_noiseless_path(easy_test_prob, μ, x0, N)
    end
end

function plot_noiseless_path(prob, μ, x0, N)
    dim = size(prob.grid)[1]
    path = compute_noiseless_path(prob, μ, x0, 50)

    path_arr = hcat(path...)

    jittered_path = path_arr + randn(size(path_arr))

    plot(path_arr[2,:], dim+1-path_arr[1,:], "b+")
    #plot(path_arr[2,:], dim+1-path_arr[1,:], "b-")
    xlim([0.5, dim+0.5])
    ylim([0.5, dim+0.5])
end