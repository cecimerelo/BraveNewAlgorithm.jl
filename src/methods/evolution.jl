include("../operators/selector.jl")
include("../operators/crossover.jl")
include("../operators/mutation.jl")
include("../methods/local_search.jl")


function evolution(population_in_castes, population_model)
    @info "Population evolving"
    alpha_reproduction_pool = selector_operator(ALPHA(), population_in_castes[ALPHA()])
    beta_reproduction_pool = selector_operator(BETA(), population_in_castes[BETA()], alpha_reproduction_pool)

    new_alpha_individuals = [
        offspring
        for individual1 in alpha_reproduction_pool,
        individual2 in alpha_reproduction_pool
        for offspring in create_new_individual(
            (individual1, individual2),
            population_model.config_parameters,
            ALPHA()
        )
    ]
    @info "New alpha individuals -> $(length(new_alpha_individuals))"
    new_beta_individuals = [
        offspring
        for individual1 in beta_reproduction_pool,
        individual2 in beta_reproduction_pool
        for offspring in create_new_individual(
            (individual1, individual2),
            population_model.config_parameters,
            BETA()
        )
    ]
    @info "New beta individuals -> $(length(new_beta_individuals))"
    lower_castes_mutated = [
        mutate_individual(individual.chromosome, population_model.config_parameters, caste)
        for caste in [GAMMA(), DELTA(), EPSILON()]
        for individual in population_in_castes[caste]
    ]
    @info "Lower castes mutated -> $(length(lower_castes_mutated))"
    return vcat(new_alpha_individuals, new_beta_individuals, lower_castes_mutated)
end

function mutate_individual(chromosome, config_parameters, caste::GAMMA)
    mutated_chromosome = mutation_operator(chromosome, config_parameters.mutation_rate[caste.name])
    return local_search(mutated_chromosome, population_model, caste)
end

function mutate_individual(chromosome, config_parameters, caste)
    return mutation_operator(chromosome, config_parameters.mutation_rate[caste.name])
end

function create_new_individual(parents, config_parameters, caste)
    offspring1, offspring2 = crossover_operator(parents)
    offspring1_mutated = mutation_operator(offspring1, config_parameters.mutation_rate[caste.name])
    offspring2_mutated = mutation_operator(offspring2, config_parameters.mutation_rate[caste.name])
    return offspring1_mutated, offspring2_mutated
end
