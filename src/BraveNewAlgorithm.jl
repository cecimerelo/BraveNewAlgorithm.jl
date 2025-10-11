module BraveNewAlgorithm
export
        Caste,
        ALPHA,
        BETA,
        GAMMA,
        DELTA,
        EPSILON,
        ConfigurationParametersEntity,
        FitnessFunction,
        PopulationModel,
        Embryo,
        Individual,
        brave_new_algorithm

    export best_element_of_population

    include("individual/castes.jl")
    include("individual/fitness_function.jl")
    include("individual/population_model.jl")
    include("brave_new_algorithm.jl")
    include("utils.jl")

    # Export necessary functions from included files
    export build_population_model,
    fertilising_room,
    multiple_fertilising_room,
    hatchery,
    assert_population_divided_in_castes_match_initial_population_size,
    evolution,
    local_search,
    read_parameters_file,
    calculate_edit_distance,
    crossover_operator,
    mutation_operator,
    selector_operator,
    create_new_individual,
    generate_chromosome
end # module
