using .BraveNewAlgorithm

using Test
using BlackBoxOptimizationBenchmarking

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

@testset "Test multiple_fertilising_room when called then all embryos have genes in range" begin
    pop_size = 10
    embryos = multiple_fertilising_room(population_model, pop_size)
    
    @test length(embryos) == pop_size
    
    for embryo in embryos
        @test length(embryo.chromosome) == config_parameters_entity.chromosome_size
        for gene in embryo.chromosome
            @test gene >= range[1] && gene <= range[2]
        end
        @test isa(embryo.f_value, Real)
    end
end

@testset "Test FitnessFunction accepts AbstractArray (views)" begin
    test_genes = rand(Uniform(range[1], range[2]), config_parameters_entity.chromosome_size, 3)
    ff = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    
    # Test with view
    result1 = ff(@view test_genes[:, 1])
    @test isa(result1, Real)
    
    # Test with regular vector
    result2 = ff(test_genes[:, 2])
    @test isa(result2, Real)
    
    # Test that calls counter is incremented
    initial_calls = ff.calls_counter
    ff(@view test_genes[:, 3])
    @test ff.calls_counter == initial_calls + 1
    @test embryo.f_value != 0
    @test fitness_function.calls_counter == 1
    @test typeof(embryo) <: Embryo
    @test typeof(embryo.chromosome) <: Vector{Float64}
    @test length(embryo.chromosome) == config_parameters_entity.chromosome_size
end