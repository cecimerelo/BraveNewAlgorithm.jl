using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking
using Test

config_file_path = "./test/Config Files/config_file_1_test.json"
chromosome = rand(10)
fitness_function = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
range = (-5.12, 5.12)
fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])

@testset "Test that Embryo is created with correct values" begin

    embryo = Embryo(chromosome, fitness_function)

    @test typeof(embryo) <: Embryo
    @test embryo.f_value != 0
    @test fitness_function.calls_counter == 1
end

@testset "Test that for this specific function fitness values for any kind of chromosome are always > 0" begin
    # generate 10 random chromosomes for the range used, and do it for 2, 3, 5, 10, 20 and 40 dimensions
    for i in [2, 3, 5, 10, 20, 40]
        chromosome = rand(range[1]:range[2], i)
        f_value = fitness_function(chromosome)
        @test f_value > 0
    end
end