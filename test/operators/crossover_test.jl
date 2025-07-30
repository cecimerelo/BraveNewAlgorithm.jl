using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking

include("../../src/utils.jl")
include("../../src/operators/crossover.jl")
include("../../src/methods/fertilising_room.jl")

using Test

config_file_path = "./test/Config Files/config_file_1_test.json"
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

parents = (
    Individual(embryos[1].chromosome, embryos[1].f_value, ALPHA()),
    Individual(embryos[2].chromosome, embryos[2].f_value, ALPHA())
)

@testset "Test crossover_operator when called the new chromosome returned" begin
    offspring = crossover_operator(parents)

    @test typeof(offspring[1]) == Array{Float64,1}
    @test typeof(offspring[2]) == Array{Float64,1}

    @test length(offspring[1]) == length(parents[1].chromosome)
    @test length(offspring[2]) == length(parents[2].chromosome)

    @test offspring[1] != parents[1].chromosome
    @test offspring[2] != parents[2].chromosome


end
