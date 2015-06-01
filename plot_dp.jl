using PyPlot

function plot_dp(μ, x₀)
    μ_seq = Array{Int64, 1}[]
    x_seq = Array{Int64, 1}[[x₀...]]
    for k in 1:size(μ)[1]
        push!(μ_seq, μ[k][x_seq[k]])
        push!(x_seq, μ_seq[k] + x_seq[k])
    end

    x_arr, y_arr = zip(x_seq...)
    println("$(x_arr)")
    println("$(y_arr)")
    plot(x_arr, y_arr)
end