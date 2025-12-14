using .BraveNewAlgorithm
using Random
using StatsBase
using Shuffle

include("../commons.jl")

function selector_operator(caste::ALPHA, caste_population)
    reproduction_pool = build_reproduction_pool(caste_population)
    return random_pairs(reproduction_pool)
end


function selector_operator(caste::BETA, caste_population, alpha_reproduction_pool)
    beta_reproduction_pool =  build_reproduction_pool(caste_population)
    alpha_reproduction_pool = from_array_of_tuples_to_array(alpha_reproduction_pool)

    reproductible_beta = sample(beta_reproduction_pool, length(alpha_reproduction_pool), replace=false)

    selected = Vector{Tuple}()
    for alpha_individual in alpha_reproduction_pool
        beta_individual = rand(reproductible_beta)
        delete_element_from_array(reproductible_beta, [beta_individual])
        tuple = (alpha_individual, beta_individual)
        push!(selected, tuple)
    end

    return selected
end

function selector_operator(caste, caste_population)
    @info "Lower caste, selection not applied"
end

function build_reproduction_pool(caste_population)
    caste_population = Shuffle.shuffle(caste_population)
    winners =
        [
            binary_tournament(caste_population) for _ in 1:2
        ]

    return vcat(winners[1], winners[2])
end

function binary_tournament(caste_population)
    n = length(caste_population)
    n2 = n >>> 1                 # floor(n/2)
    # If odd, one element will be ignored; alternatively, handle wrap-around as desired.

    # Shuffle indices to avoid moving/populating elements
    idx = collect(1:n)
    Random.shuffle!(idx)

    pool = Vector{eltype(caste_population)}(undef, n2)
    j = 1
    @inbounds for k in 1:n2
        x = caste_population[idx[j]]
        y = caste_population[idx[j+1]]
        j += 2

        fx = x.f_value
        fy = y.f_value

        if fx < fy
            pool[k] = x
        elseif fx > fy
            pool[k] = y
        else
            pool[k] = ifelse(rand(Bool), x, y)  # no alloc
        end
    end
    return pool
end