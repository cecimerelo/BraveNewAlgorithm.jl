include("../operators/selector.jl")
include("../operators/crossover.jl")
include("../methods/local_search.jl")


function evolution(population_in_castes, population_model)
    @info "\n\n→ Population evolving"
    
    # Elitism: preserve the best individual from current population
    all_individuals = vcat(
        population_in_castes[ALPHA()],
        population_in_castes[BETA()],
        population_in_castes[GAMMA()],
        population_in_castes[DELTA()],
        population_in_castes[EPSILON()]
    )
    best_individual = all_individuals[argmin([ind.f_value for ind in all_individuals])]
    
    alpha_reproduction_pool = selector_operator(ALPHA(), population_in_castes[ALPHA()])

    new_alpha_individuals = [
        create_new_individual(
            alpha_parents,
            population_model.config_parameters.mutation_rate[ALPHA().name],
            population_model.range
        )
        for alpha_parents in alpha_reproduction_pool
    ]

    beta_reproduction_pool = selector_operator(BETA(), population_in_castes[BETA()], alpha_reproduction_pool)
    new_beta_individuals = [
        create_new_individual(
            alpha_beta_parents,
            population_model.config_parameters.mutation_rate[BETA().name],
            population_model.range
        )
        for alpha_beta_parents in beta_reproduction_pool
    ]

    lower_castes_mutated = vcat(
        [
            mutate_individual(
                individual.chromosome, 
                population_model.config_parameters.mutation_rate[caste.name],
                population_model.range
            )
            for caste in [DELTA(), EPSILON()]
            for individual in population_in_castes[caste]
        ],
        [
            mutate_individual(
                individual.chromosome,
                population_model.config_parameters.mutation_rate[GAMMA().name],
                population_model.fitness_function,
                GAMMA(),
                population_model.config_parameters.max_generations,
                population_model.range
            )
            for individual in population_in_castes[GAMMA()]
        ]
    )

    new_generation = [ collect(Iterators.flatten(new_alpha_individuals));
        collect(Iterators.flatten(new_beta_individuals));
        lower_castes_mutated ]
    
    # Elitism: if best individual was lost, replace worst individual with it
    new_embryos = [Embryo(chromosome, population_model.fitness_function) for chromosome in new_generation]
    new_best_fitness = minimum([embryo.f_value for embryo in new_embryos])
    
    if new_best_fitness > best_individual.f_value
        # Best individual was lost, replace the worst with it
        worst_idx = argmax([embryo.f_value for embryo in new_embryos])
        new_generation[worst_idx] = best_individual.chromosome
    end
    
    return new_generation
end

function mutate_individual(chromosome, mutation_probability, fitness_function, caste::GAMMA, max_generations, range)
    mutated_chromosome = gaussian_mutation_operator(chromosome, mutation_probability, range)
    return local_search(mutated_chromosome, fitness_function, mutation_probability, caste, range, max_generations)
end

function mutate_individual(chromosome, mutation_probability, range)
    return mutation_operator(chromosome, mutation_probability)
end

function create_new_individual(parents, mutation_rate, range)
    offspring1, offspring2 = crossover_operator(parents)
    offspring1_mutated = gaussian_mutation_operator(offspring1, mutation_rate, range)
    offspring2_mutated = gaussian_mutation_operator(offspring2, mutation_rate, range)
    return offspring1_mutated, offspring2_mutated
end
