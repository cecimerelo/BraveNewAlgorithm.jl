using Pkg
Pkg.activate(".")

include("../src/BraveNewAlgorithm.jl")

include("configuration_parameters_entity_test.jl")
include("methods/evolution_test.jl")
include("methods/create_new_individual.jl")
include("methods/from_genes_to_embryo_test.jl")
include("methods/hatchery_test.jl")
include("methods/fertilising_room_test.jl")
include("methods/local_search_test.jl")
include("operators/crossover_test.jl")
include("operators/mutation_test.jl")
include("operators/selector_test.jl")
include("commons_test.jl")
include("utils_test.jl")
include("individuals_test.jl")
