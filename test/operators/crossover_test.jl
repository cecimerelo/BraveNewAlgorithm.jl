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

@testset "Test crossover_operator returns corrects and different individuals from parents" for i in 1:length(embryos)-1, j in i+1:length(embryos)
    parents = (
        Individual(embryos[i].chromosome, embryos[i].f_value, ALPHA()),
        Individual(embryos[j].chromosome, embryos[j].f_value, ALPHA())
    )

    offspring = crossover_operator(parents)

    @test typeof(offspring[1]) == Array{Float64,1}
    @test typeof(offspring[2]) == Array{Float64,1}

    @test length(offspring[1]) == length(parents[1].chromosome)
    @test length(offspring[2]) == length(parents[2].chromosome)

    @test offspring[1] != parents[1].chromosome
    @test offspring[2] != parents[2].chromosome

end
