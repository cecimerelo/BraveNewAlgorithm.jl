using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking
using Test

@testset "Test that Embryo is created with correct values" begin
    config_file_path = "./test/Config Files/config_file_1_test.json"
    chromosome = rand(10)
    fitness_function = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
    range = (-5.12, 5.12)
    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    embryo = Embryo(chromosome, fitness_function)

    @test typeof(embryo) == Embryo
    @test embryo.f_value != 0
    @test fitness_function.calls_counter == 1
end