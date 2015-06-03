# easy_test: Look for obvious mistakes
require("ono.jl");

function easy_test(alg, x0=[1, 1], plot=false, N=5,
                   alg_args=(); to_return=(), alg_kwargs=(Any => Any)[])
    grid = [0 0; 0 0]
    g_N(x) = x == [2, 2]? 0 : 1
    g_k(k, x, u) = norm(u)
    Δ = 0.1
    σ² = 1
    d = 1.5 # 1-diagonals ok but not 2 in a row

    return_val_dict = (Symbol => Any)[]
    return_val_dict[:easy_test_prob] = 
                        ChanceConstrainedProblem(grid, g_N, g_k, Δ, σ², d)
    return_val_dict[:x0] = x0

    if :J in to_return or :μ in to_return
        return_val_dict[:J], return_val_dict[:μ] =
            alg(easy_test_prob, x0, alg_args...; N=N, alg_kwargs...)
    end

    if plot
        plot_noiseless_path(easy_test_prob, μ, x0, N)
    end

    return tuple([return_val_dict[key] for key in to_return]...)
end

# Δ = 0.001 goes around RHS
# Δ = 0.01 goes around LHS
function interesting_test(alg, alg_args=();
                          N=50, x0=[3, 18], plot=false,
                          to_return=(),
                          alg_kwargs=(Any => Any)[])
    grid = zeros(20, 20)
    # Obstacle 1: rows 5-16, cols 6-7
    grid[5:16, 6:7] = 1
    # Obstacle 2: rows 5-8, cols 11-16; rows 9-16, cols 13-16
    grid[5:8, 11:16] = 1
    grid[9:16, 13:16] = 1
    x_goal = [12, 10]
    g_N(x) = x == x_goal? 0: 1
    g_k(k, x, u) = 1e-5 * norm(u)
    Δ = 0.001 #or 0.01
    σ² = 0.2
    d = 1
    return_val_dict = (Symbol => Any)[]
    return_val_dict[:interesting_test_prob] = 
                        ChanceConstrainedProblem(grid, g_N, g_k, Δ, σ², d)

    return_val_dict[:x0] = x0

    if :J in to_return or :μ in to_return
        return_val_dict[:J], return_val_dict[:μ] =
            alg(interesting_test_prob, x0, alg_args...; N=N, alg_kwargs...)
    end

    if plot
        plot_noiseless_path(interesting_test_prob, μ, x0, N)
    end

    return tuple([return_val_dict[key] for key in to_return]...)
end

interesting_test_prob, interesting_test_x0 = interesting_test(nothing,
    to_return=(:interesting_test_prob, :x0))

function plot_noiseless_path(prob, μ, x0, N; color=nothing)
    dim = size(prob.grid)[1]
    path = compute_noiseless_path(prob, μ, x0, 50)

    path_arr = hcat(path...)

    jittered_path = path_arr + randn(size(path_arr))/20

    if color == nothing
        color = (0, 0, 1)
    end
    plot(jittered_path[2,:], dim+1-jittered_path[1,:], "-+", color=color)
    #plot(jittered_path[2,:], dim+1-jittered_path[1,:], "+", color=color)
    xlim([0.5, dim+0.5])
    ylim([0.5, dim+0.5])
end
