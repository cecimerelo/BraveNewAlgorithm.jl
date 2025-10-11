using BlackBoxOptimizationBenchmarking
using Test

fitness_function = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
range = (-5.12, 5.12)

@testset "Test that for this specific function fitness values for any kind of chromosome are always > 0" begin
    for size in [2, 3, 5, 10, 20, 40]
        for j in 1:10000
            chromosome = rand(range[1]:range[2], size)
            f_value = fitness_function(chromosome)
            @test f_value > 0
        end
    end
end