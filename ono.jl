#=
    ono.jl
    Gabriel Ehrlich and Matt Staib
    AA 203, Spring 2015
    Final Project

    Implementation of Ono et. al. CCPD algorithm
=#

require("chance_constrained_problem.jl")

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
            prob.g_N(x) + prob.grid[x[1], x[2]]*λ
        else
            error("k = $(k) but must be in interval [0, N]")
        end
    end

    function get_feas_u(x)
        feas_u = Vector{Int64}[]

        for u_x in -prob.d:prob.d
            for u_y in -prob.d:prob.d
                u = [u_x, u_y]

                if norm(u) <= prob.d && all(x + u .>= [1,1]) && all(x + u .<= [size(prob.grid)...])
                    push!(feas_u, u)
                end
            end
        end

        return feas_u
    end

    h, w = size(prob.grid)

    J = zeros(h, w, N+1)

    for i = 1:h
        for j = 1:w
            J[i,j,N+1] = L(N, [i,j], nothing)
        end
    end

    # will hold our policies
    μ = [ (Vector{Int64} => Vector{Int64})[] for k in 0:N-1 ]
    for k in N-1:-1:0
        J_this = copy(J)
        for i = 1:h
            for j = 1:w
                x = [i,j]

                action_tuples = [(L(k, x, u) + sum(get_probs(prob, x+u).*J[:,:,k+2]), tuple(u...)) 
                    for u in get_feas_u(x)]

                best_u_ind = indmin(action_tuples)
                
                best_J, best_u = action_tuples[best_u_ind]
                J[i,j,k+1] = best_J
                μ[k+1][[i,j]] = [best_u...]
            end
        end
    end

    return J, μ
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
