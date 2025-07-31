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

    # Export all necessary types and functions from included files
    include("utils.jl")
    include("commons.jl")
    include("operators/crossover.jl")
    include("operators/mutation.jl")
    include("operators/selector.jl")
    include("methods/hatchery.jl")
    include("methods/evolution.jl")
    include("methods/fertilising_room.jl")
    include("methods/local_search.jl")

    # Export necessary functions from included files
    export build_population_model, fertilising_room, hatchery, evolution, local_search
end # module
