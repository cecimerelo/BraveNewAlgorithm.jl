using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking
using Test

@testset "Test from_genes_to_embryo method when called the individual created" begin
    config_file_path = "./test/Config Files/config_file_1_test.json"
    chromosome = rand(10)

    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    individual = Embryo(chromosome, fitness_function)

    @test typeof(individual) == Embryo
    @test individual.f_value != 0
end
