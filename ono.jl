#=
    ono.jl
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

function prob_of_this_square(x, center, σ²)
    return mvnun(x - [0.5, 0.5], x + [0.5, 0.5], center, σ²*eye(2))[1]
end

#probs_cache = (Tuple{Array{Bool,2},Float64} => Array)[]
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
    return probs_big[1+h-i:h+h-i, 1+w-j:w+w-j]
end

# returns ??
function ono_dp(prob, λ, N)
    function L(k, x, u)
        if u == nothing
            u = (0, 0)
        end

        if k == 0
            prob.g_k(k, x, u) 
        elseif 0 < k < N
            prob.g_k(k, x, u) + prob.grid[x[1], x[2]]*λ
        elseif k == N
            prob.g_N(k, x) + prob.grid[x[1], x[2]]*λ
        else
            error("k = $(k) but must be in interval [0, N]")
        end
    end

    function get_feas_u(x)
        feas_u = Vector{Int64}[]

        for u_x in -prob.d:prob.d
            for u_y in -prob.d:prob.d
                u = [u_x, u_y]

                if norm(u) <= prob.d #& all(u .>= [1,1]) & all(u .<= 
                    push!(feas_u, u)
                end
            end
        end

        return feas_u
    end

    h, w = size(prob.grid)

    J = zeros(size(prob.grid))
    for i = 1:h
        for j = 1:w
            J[i,j] = L(N, (i,j), nothing)
        end
    end

    for k in N-1:-1:0
        J_this = copy(J)
        for i = 1:h
            for j = 1:w
                x = [i,j]

                probs = get_probs(prob, x)

                action_tuples = [(L(k, x, u) + sum(probs.*J), tuple(u...)) for u in get_feas_u(x)]
                best_u_ind = indmax(action_tuples)
                
                best_J, best_u = action_tuples[best_u_ind]
                J_this[i,j] = best_J
                # do something with best_u
            end
        end

        J = J_this
    end

    return J
end

function build_test_prob(dim)
    grid_int = zeros(dim,dim)
    grid_int[3:4,3:4] = 1
    grid = convert(Array{Bool}, grid_int)

    g_N(k, x) = x == [dim,dim]? 0 : 1
    g_k(k, x, u) = 0.0001 * norm(u)
    Δ = 0.2
    σ² = 1
    d = 2

    prob = ChanceConstrainedProblem(grid, g_N, g_k, Δ, σ², d)

    return prob
end

function test_ono_dp(λ, dim)
    N = 50

    prob = build_test_prob(dim)

    J = ono_dp(prob, λ, N)

    return J
end

# Function containing Ono algorithm
# N is time horizon
function ono_solve(prob, eps_d=1e-5, N=50)
    #=
        Steps 1-4: Check if unconstrained solution meets contraints
    =#

    #=
        Steps 5-8: Check if a feasible solution exists
    =#

    #=
        Steps 9-20: Main loop of algorithm
    =#
end
