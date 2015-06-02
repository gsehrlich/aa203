#=
    chance_constrained_problem.jl
    Gabriel Ehrlich and Matt Staib
    AA 203, Spring 2015
    Final Project

    Implementation of Ono et. al. CCPD algorithm
=#

using PyCall
@pyimport scipy.stats.mvn as mvn
mvnun = convert(Function, mvn.mvnun)

type ChanceConstrainedProblem
    # Val at each point is false if in bounds else true
    grid::Array{Bool,2}
    g_N::Function
    g_k::Function
    Δ::Float64
    #f::Function

    σ²::Float64 #noise
    d::Float64 #controller bound
end

function get_feas_u(prob, x)
    feas_u = Vector{Int64}[]

    square_semidim = int(prob.d)
    for u_x in -square_semidim:square_semidim
        for u_y in -square_semidim:square_semidim
            u = [u_x, u_y]

            if norm(u) <= prob.d && all(x + u .>= [1,1]) && all(x + u .<= [size(prob.grid)...])
                push!(feas_u, u)
            end
        end
    end

    return feas_u
end

function prob_of_this_square(x, center, σ²)
    return mvnun(x - [0.5, 0.5], x + [0.5, 0.5], center, σ²*eye(2))[1]
end

probs_cache = (Any => Array)[]
function get_probs(prob, x)
    h, w = size(prob.grid)

    tup = (prob.grid, prob.σ²)

    if haskey(probs_cache, tup)
        probs_big = probs_cache[tup]
    else
        # this is expensive
        probs_big = zeros(2*h-1, 2*w-1)
        for i = 1:2*h-1
            for j = 1:2*w-1
                probs_big[i, j] = prob_of_this_square([i, j], [h, w], prob.σ²)
            end
        end

        probs_cache[tup] = probs_big
    end 

    i, j = x
    probs = probs_big[1+h-i:h+h-i, 1+w-j:w+w-j] 
    return probs/sum(probs)
end

# easy_test: Look for obvious mistakes
function easy_test()
    grid = [0 0; 0 0]
    g_N(x) = x == [2, 2]? 0 : 1
    g_k(k, x, u) = norm(u)
    Δ = 0.1
    σ² = 1
    d = 1.5 # 1-diagonals ok but not 2 in a row
    easy_test = ChanceConstrainedProblem(grid, g_N, g_k, Δ, σ², d)
end

function build_test_prob(dim, α = 1e-5)
    grid_int = zeros(dim, dim)
    grid_int[1:2, 1:2] = 1
    grid = convert(Array{Bool}, grid_int)

    g_N(x) = x == [dim,dim]? 0 : 1
    g_k(k, x, u) = α * norm(u)
    Δ = 0.2
    σ² = 1
    d = 2

    prob = ChanceConstrainedProblem(grid, g_N, g_k, Δ, σ², d)

    return prob
end

function compute_noiseless_path(prob, μ, x0, N)
    path = typeof(x0)[]
    push!(path, x0)

    for k = 1:length(μ)
        x = path[k]
        push!(path, x + μ[k][x])
    end
        
    return path
end
