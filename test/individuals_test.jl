using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking
using Test

config_file_path = "./test/Config Files/config_file_1_test.json"
fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
range = (-5.12, 5.12)
@info "Values for 1,1 $(fitness_function([1,1]))"
@info "Values for 0,0 $(fitness_function([0,0]))"
@info "f_opt $(fitness_function.fitness_function.f_opt)"
@info "x_opt $(fitness_function.fitness_function.x_opt)"

@testset "Test that Embryo is created with correct values" begin
    ff_called = 0
    for size in [2, 3, 5, 10, 20, 40]
        for j in 1:1000
            chromosome = generate_chromosome(range, size)
            embryo = Embryo(chromosome, fitness_function)
            @test typeof(embryo) <: Embryo
            @test embryo.f_value > 0
            @test fitness_function.calls_counter == ff_called + 3
            ff_called += 1
        end
    end
end

@testset "Test that for this specific function fitness values for any kind of chromosome are always > 0" begin
    for size in [2, 3, 5, 10, 20, 40]
        for j in 1:10
            chromosome = generate_chromosome(range, size)
            f_value = fitness_function(chromosome)
            @test f_value > 0
        end
    end
end