#=
    ono.jl
    Gabriel Ehrlich and Matt Staib
    AA 203, Spring 2015
    Final Project

    Implementation of Ono et. al. CCPD algorithm
=#

type ChanceConstrainedProblem
    # Val at each point is true if in bounds else false
    grid::Array
    g_N::Function
    g_k::Function
    Delta::Float64
end

function ono_dp(prob, N)
    L(lambda, k, x_k, u_k) = k == 0? prob.g_k(k, x_k, u_k) :
            0 < k < N? prob.g_k(k, x_k, u_k) + prob.grid[x_k]*lambda :
                       prob.g_k
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