using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking
using Test

config_file_path = "./test/Config Files/config_file_1_test.json"
fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
range = (-5.12, 5.12)

@testset "Test that Embryo is created with correct values" begin
    ff_called = 0
    for i in [2, 3, 5, 10, 20, 40]
        for j in 1:10
            chromosome = generate_chromosome(range, i)
            embryo = Embryo(chromosome, fitness_function)
            @test typeof(embryo) <: Embryo
            @test embryo.f_value > 0
            @test fitness_function.calls_counter == ff_called + 1
            ff_called += 1
        end
    end
end

@testset "Test that for this specific function fitness values for any kind of chromosome are always > 0" begin
    for i in [2, 3, 5, 10, 20, 40]
        for j in 1:10
            chromosome = generate_chromosome(range, i)
            f_value = fitness_function(chromosome)
            @test f_value > 0
        end
    end
end