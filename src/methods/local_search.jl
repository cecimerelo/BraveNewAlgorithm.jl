include("../operators/mutation.jl")

const MAX_LOCAL_SEARCH_ITERATIONS = 5
function local_search(offspring, fitness_function, mutation_rate, caste::GAMMA)
    embryo = Embryo(offspring, fitness_function)
    f_value = embryo.f_value
    final_chromosome = offspring
    local_search_iterations = 0
    improved = true

    while improved
        mutated_offspring = mutation_operator(final_chromosome, mutation_rate)
        new_embryo = Embryo(mutated_offspring, fitness_function)

        if new_embryo.f_value >= f_value || new_embryo.f_value <= fitness_function.fitness_function.f_opt
            local_search_iterations = local_search_iterations + 1
            if local_search_iterations >= MAX_LOCAL_SEARCH_ITERATIONS
                improved = false
            end
        else
            f_value = new_embryo.f_value
            final_chromosome = mutated_offspring
        end
    end

    return final_chromosome

end

function local_search(offspring, fitness_function, mutation_rate, caste)
    return offspring
end