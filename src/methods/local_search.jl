include("../operators/mutation.jl")

function local_search(offspring, population_model, caste::GAMMA)
    embryo = Embryo(offspring, population_model.fitness_function)
    f_value = embryo.f_value
    final_chromosome = offspring
    local_search_iterations = 0
    improved = true

    while improved
        mutated_offspring = mutation_operator(final_chromosome, population_model.config_parameters.mutation_rate[caste.name])
        new_embryo = Embryo(mutated_offspring, population_model.fitness_function)

        if new_embryo.f_value >= f_value || new_embryo.f_value <= population_model.fitness_function.fitness_function.f_opt
            improved = false
            break
        end

        f_value = new_embryo.f_value
        final_chromosome = mutated_offspring
        local_search_iterations = local_search_iterations + 1
    end

    return final_chromosome

end

function local_search(offspring, population_model, caste)
    return offspring
end