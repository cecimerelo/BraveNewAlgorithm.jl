include("../operators/selector.jl")
include("../operators/crossover.jl")
include("../methods/local_search.jl")


function evolution(population_in_castes, population_model)
    @info "\n\n→ Population evolving"
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
            mutate_individual(individual.chromosome, population_model.config_parameters.mutation_rate[DELTA().name], population_model.range)
            for individual in population_in_castes[DELTA()]
        ],
        [
            mutate_individual(
                individual.chromosome,
                population_model.config_parameters.mutation_rate[EPSILON().name],
                population_model.range,
                population_model.fitness_function,
                EPSILON(),
                population_model.config_parameters.max_generations
            )
            for individual in population_in_castes[EPSILON()]
        ],
        [
            mutate_individual(
                individual.chromosome,
                population_model.config_parameters.mutation_rate[GAMMA().name],
                population_model.range,
                population_model.fitness_function,
                GAMMA(),
                population_model.config_parameters.max_generations
            )
            for individual in population_in_castes[GAMMA()]
        ]
    )

    return [ collect(Iterators.flatten(new_alpha_individuals));
        collect(Iterators.flatten(new_beta_individuals));
        lower_castes_mutated ]
end

function mutate_individual(chromosome, mutation_probability, range, fitness_function, caste::EPSILON, max_generations = 10)
    return local_search(chromosome, fitness_function, mutation_probability, range, caste, max_generations)
end

function mutate_individual(chromosome, mutation_probability, range, fitness_function, caste::GAMMA, max_generations = 10)
    mutated_chromosome = mutation_operator(chromosome, mutation_probability, range)
    return local_search(mutated_chromosome, fitness_function, mutation_probability, range, caste)
end

function mutate_individual(chromosome, mutation_probability, range)
    return mutation_operator(chromosome, mutation_probability, range)
end

function create_new_individual(parents, mutation_rate, range)
    offspring1, offspring2 = crossover_operator(parents)
    offspring1_mutated = mutation_operator(offspring1, mutation_rate, range)
    offspring2_mutated = mutation_operator(offspring2, mutation_rate, range)
    return offspring1_mutated, offspring2_mutated
end
