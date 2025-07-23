using .BraveNewAlgorithm

using Test
using BlackBoxOptimizationBenchmarking

include("../../src/methods/fertilising_room.jl")
include("../../src/utils.jl")

config_file_path = "./test/Config Files/config_file_1_test.json"
config_parameters_entity = read_parameters_file(config_file_path)
fitness_function = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
range = (-5.12, 5.12)
minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt
fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
population_model = PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)
embryo = fertilising_room(population_model)

@testset "Test fertilising_room when called then chromosome genes are in range" begin
    for gene in embryo.chromosome
        (@test gene >= range[1] && gene <= range[2])
    end
end