#=
    ono.jl
    Gabriel Ehrlich and Matt Staib
    AA 203, Spring 2015
    Final Project

    Implementation of Ono et. al. CCPD algorithm
=#
using PyPlot

require("chance_constrained_problem.jl")
require("general_dp.jl")

function risk_to_go(prob, N, μ)
    h, w = size(prob.grid)

    r = zeros(h, w, N+1)
    for i = 1:h
        for j = 1:w
            r[i, j, N+1] = int(prob.grid[i, j])
        end
    end

    for k in N-1:-1:0
        for i = 1:h
            for j = 1:w
                x = [i,j]
                u = μ[k+1][x]

                r[i, j, k+1] = int(prob.grid[i, j]) + sum(get_probs(prob, x+u).*r[:,:,k+2])
            end
        end
    end

    return r[:,:,1]
end

function compute_Δ_min(prob, N)
    function g(k, x, u)
        if 0 <= k <= N
            int(prob.grid[x...])
        else
            error("k = $(k) but must be in interval [0, N]")
        end
    end
            
    J, μ = dp(prob, N, g, get_feas_u, get_probs)

    return J[:,:,1]
end

function ono_dp(prob, λ, N)
    function L(k, x, u)
        if u == nothing
            u = (0, 0)
        end

        if k == 0
            prob.g_k(k, x, u)
        elseif 0 < k < N
            prob.g_k(k, x, u) + prob.grid[x...]*λ
        elseif k == N
            prob.g_N(x) + prob.grid[x...]*λ
        else
            error("k = $(k) but must be in interval [0, N]")
        end
    end

    return dp(prob, N, L, get_feas_u, get_probs)
end

function test_ono_dp(λ, dim, N=50, α=1e-5)
    prob = build_test_prob(dim, α)

    J, μ = ono_dp(prob, λ, N)

    return J, μ
end

# Function containing Ono algorithm
# N is time horizon
function ono_solve(prob, x0, eps_d=1e-5, N=50)
    #=
        Steps 1-4: Check if unconstrained solution meets contraints
    =#

    function r_and_μ(λ)
        J, μ = ono_dp(prob, λ, N)
        r = risk_to_go(prob, N, μ)

        return r[x0...], μ
    end

    r, μ = r_and_μ(0)
    if r - prob.Δ <= 0
        return μ
    end

    #=
        Steps 5-8: Check if a feasible solution exists
    =#

    Δ_min = compute_Δ_min(prob, N)
    if Δ_min[x0...] > prob.Δ
        return "Infeasible" #throw this error more intelligently
    end

    #=
        Steps 9-20: Main loop of algorithm
    =#

    λ⁺ = 1
    while r_and_μ(λ⁺)[1] - prob.Δ > 0
        λ⁺ *= 2
    end

    λᴸ = 0
    λᵁ = λ⁺

    rᵁ, μᵁ = r_and_μ(λᵁ)

    while (λᴸ - λᵁ) * (rᵁ - prob.Δ) > eps_d
        λ = (λᴸ + λᵁ) / 2

        r, μ = r_and_μ(λ)
        if r - prob.Δ == 0
            return μ
        elseif r - prob.Δ < 0
            λᵁ = λ
            rᵁ = r
        else
            λᴸ = λ
        end
    end

    return μ
end

#takes 6.45 seconds with full probability map
function test_full_ono(dim=5)
    prob = build_test_prob(dim, 1e-5);
    x0 = [1,3];
    μ = ono_solve(prob, x0);

    path = compute_noiseless_path(prob, μ, x0, 50)

    path_arr = hcat(path...)

    plot(path_arr[2,:], dim+1-path_arr[1,:], "b+")
    xlim([0.5, dim+0.5])
    ylim([0.5, dim+0.5])
end
