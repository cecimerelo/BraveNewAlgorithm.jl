using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking

using Test

include("../../src/utils.jl")
include("../../src/methods/hatchery.jl")
include("../../src/methods/evolution.jl")
include("../../src/operators/selector.jl")
include("../../src/operators/crossover.jl")
include("../../src/methods/fertilising_room.jl")

for config_file in ["config_file_1_test.json", "config_file_2_test.json", "config_file_3_test.json"]
    config_file_path = "../test/Config Files/$(config_file)"
    @info "Testing evolution for $(config_file)"
    config_parameters_entity = read_parameters_file(config_file_path)
    fitness_function = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
    range = (-5.12, 5.12)
    minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt
    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    population_model = PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)
    embryos = [
        fertilising_room(population_model)
        for _ in 1:population_model.config_parameters.population_size
    ]

    population_in_castes = hatchery(population_model, embryos)

    @testset "Test evolution when called then new population returned for $(config_file)" begin
        new_generation = evolution(population_in_castes, population_model)

        @test length(new_generation) == population_model.config_parameters.population_size
    end
end
