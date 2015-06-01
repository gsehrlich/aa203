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

function dp(prob, N, g, get_feas_u, get_probs)
    h, w = size(prob.grid)

    J = zeros(h, w, N+1)

    for i = 1:h
        for j = 1:w
            J[i,j,N+1] = g(N, [i,j], nothing)
        end
    end

    # will hold our policies
    μ = [ (Vector{Int64} => Vector{Int64})[] for k in 0:N-1 ]
    for k in N-1:-1:0
        for i = 1:h
            for j = 1:w
                x = [i,j]

                action_tuples = [(g(k, x, u) + sum(get_probs(prob, x+u).*J[:,:,k+2]), tuple(u...)) 
                    for u in get_feas_u(prob, x)]

                best_u_ind = indmin(action_tuples)
                
                best_J, best_u = action_tuples[best_u_ind]
                J[i,j,k+1] = best_J
                μ[k+1][[i,j]] = [best_u...]
            end
        end
    end

    return J, μ
end
