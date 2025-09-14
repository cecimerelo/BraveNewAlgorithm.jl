"""
    mutation_operator(offspring, mutation_percentage)

Apply mutation to `offspring` based on `mutation_percentage`.
"""
function mutation_operator(offspring, mutation_percentage)
    mutated_offspring = Array{Float64,1}()
    genes_to_mutate = floor(Int, mutation_rate * length(offspring) / 100)
    indexes_to_mutate = rand(1:length(offspring), genes_to_mutate)

    for (index, gene) in enumerate(offspring)
        if index in indexes_to_mutate
            new_gene = rand()
            push!(mutated_offspring, new_gene)
        else
            push!(mutated_offspring, gene)
        end
    end

    return mutated_offspring
end