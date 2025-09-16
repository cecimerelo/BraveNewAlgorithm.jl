include("../operators/selector.jl")
include("../operators/crossover.jl")
include("../methods/local_search.jl")


function evolution(population_in_castes, population_model)
    @info "\n\n→ Population evolving"
    alpha_reproduction_pool = selector_operator(ALPHA(), population_in_castes[ALPHA()])

    new_alpha_individuals = [
        create_new_individual(
            alpha_parents,
            population_model.config_parameters.mutation_rate[ALPHA().name]
        )
        for alpha_parents in alpha_reproduction_pool for _ in 1:2
    ]
    @info "New alpha individuals -> $(length(new_alpha_individuals))"

    beta_reproduction_pool = selector_operator(BETA(), population_in_castes[BETA()], alpha_reproduction_pool)
    @info "Beta reproduction pool -> $(length(beta_reproduction_pool))"
    new_beta_individuals = [
        create_new_individual(
            alpha_beta_parents,
            population_model.config_parameters.mutation_rate[BETA().name]
        )
        for alpha_beta_parents in beta_reproduction_pool for _ in 1:2
    ]

    @info "New beta individuals -> $(length(new_beta_individuals))"
    lower_castes_mutated = vcat(
        [
            mutate_individual(
                individual.chromosome,
                population_model.config_parameters.mutation_rate[GAMMA().name],
                population_model.fitness_function,
                GAMMA()
            )
            for individual in population_in_castes[GAMMA()]
        ],
        [
            mutate_individual(individual.chromosome, population_model.config_parameters.mutation_rate[caste.name])
            for caste in [DELTA(), EPSILON()]
            for individual in population_in_castes[caste]
        ]
    )
    @info "Lower castes mutated -> $(length(lower_castes_mutated))"

    return vcat(new_alpha_individuals, new_beta_individuals, lower_castes_mutated)
end

function mutate_individual(chromosome, mutation_probability, fitness_function, caste::GAMMA)
    mutated_chromosome = mutation_operator(chromosome, mutation_probability)
    return local_search(mutated_chromosome, fitness_function, mutation_probability, caste)
end

function mutate_individual(chromosome, mutation_probability)
    return mutation_operator(chromosome, mutation_probability)
end

function create_new_individual(parents, mutation_rate)
    offspring1, offspring2 = crossover_operator(parents)
    offspring1_mutated = mutation_operator(offspring1, mutation_rate)
    offspring2_mutated = mutation_operator(offspring2, mutation_rate)
    return offspring1_mutated, offspring2_mutated
end
