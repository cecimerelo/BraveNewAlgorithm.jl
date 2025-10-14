using .BraveNewAlgorithm

using Test
using BlackBoxOptimizationBenchmarking

config_file_path = "./test/Config Files/config_file_1_test.json"
config_parameters_entity = read_parameters_file(config_file_path)
function_to_optimize = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
range = (-5.12, 5.12)
minimum_comparator = comparator(element, ff) = element >= ff.f_opt
fitness_function = FitnessFunction(function_to_optimize)
population_model = PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)
embryos = [
    fertilising_room(population_model)
    for _ in 1:population_model.config_parameters.population_size
]

mutated_chromosomes = [mutation_operator(embryo.chromosome, config_parameters_entity.mutation_rate["ALPHA"]) for embryo in embryos]

@testset "Test mutation_operator when called then different chromosome returned" begin
    for (embryo, mutated_chromosome) in zip(embryos, mutated_chromosomes)
        @test embryo.chromosome != mutated_chromosome
    end
end

# Test Gaussian mutation operator
@testset "Test gaussian_mutation_operator basic functionality" begin
    test_chromosome = [0.5, 1.0, -2.0, 3.0, -1.5]
    mutation_rate = 50  # 50% mutation rate
    test_range = (-5.12, 5.12)
    
    # Test with default sigma
    mutated = gaussian_mutation_operator(test_chromosome, mutation_rate, test_range)
    
    @test length(mutated) == length(test_chromosome)
    @test typeof(mutated) == Array{Float64,1}
    @test eltype(mutated) == Float64
    
    # Check all values are within range
    for gene in mutated
        @test gene >= test_range[1] && gene <= test_range[2]
    end
end

@testset "Test gaussian_mutation_operator respects range bounds" begin
    # Test edge case near boundaries
    test_chromosome = [5.0, -5.0, 0.0]
    mutation_rate = 99  # High mutation rate (must be < 100)
    test_range = (-5.12, 5.12)
    
    # Run multiple times to ensure clamping works
    for _ in 1:10
        mutated = gaussian_mutation_operator(test_chromosome, mutation_rate, test_range)
        for gene in mutated
            @test gene >= test_range[1] && gene <= test_range[2]
        end
    end
end

@testset "Test gaussian_mutation_operator with different sigma values" begin
    test_chromosome = [0.0, 0.0, 0.0, 0.0, 0.0]
    mutation_rate = 99  # High mutation rate (must be < 100)
    test_range = (-5.12, 5.12)
    
    # Test with small sigma (should produce smaller changes)
    mutated_small = gaussian_mutation_operator(test_chromosome, mutation_rate, test_range, 5.0)
    
    # Test with large sigma (should produce larger changes)
    mutated_large = gaussian_mutation_operator(test_chromosome, mutation_rate, test_range, 50.0)
    
    @test all(gene >= test_range[1] && gene <= test_range[2] for gene in mutated_small)
    @test all(gene >= test_range[1] && gene <= test_range[2] for gene in mutated_large)
end

@testset "Test gaussian_mutation_operator preserves some genes" begin
    test_chromosome = [1.0, 2.0, 3.0, 4.0, 5.0]
    mutation_rate = 20  # Only 20% should be mutated
    test_range = (-5.12, 5.12)
    
    mutated = gaussian_mutation_operator(test_chromosome, mutation_rate, test_range)
    
    # Count how many genes changed
    changes = sum(test_chromosome .!= mutated)
    expected_changes = floor(Int, mutation_rate * length(test_chromosome) / 100)
    
    @test changes == expected_changes
end

@testset "Test gaussian_mutation_operator argument validation" begin
    test_chromosome = [0.0, 0.0]
    test_range = (-5.0, 5.0)
    
    # Test invalid mutation percentage
    @test_throws ArgumentError gaussian_mutation_operator(test_chromosome, 0, test_range)
    @test_throws ArgumentError gaussian_mutation_operator(test_chromosome, 100, test_range)
    @test_throws ArgumentError gaussian_mutation_operator(test_chromosome, -10, test_range)
    @test_throws ArgumentError gaussian_mutation_operator(test_chromosome, 150, test_range)
    
    # Test invalid sigma percentage
    @test_throws ArgumentError gaussian_mutation_operator(test_chromosome, 50, test_range, 0)
    @test_throws ArgumentError gaussian_mutation_operator(test_chromosome, 50, test_range, -10)
    @test_throws ArgumentError gaussian_mutation_operator(test_chromosome, 50, test_range, 150)
    
    # Test valid cases don't throw
    @test isa(gaussian_mutation_operator(test_chromosome, 50, test_range), Array{Float64,1})
    @test isa(gaussian_mutation_operator(test_chromosome, 99, test_range, 20.0), Array{Float64,1})
end

# parents = (
#     Individual(embryos[1].chromosome, embryos[1].f_value, ALPHA()),
#     Individual(embryos[2].chromosome, embryos[2].f_value, ALPHA())
# )

# offspring = crossover_operator(parents, config_parameters_entity)
# @info "Offspring -> $(offspring)"
# @testset "Test mutation_operator when called then different chromosomes returned" begin
#     mutated_offspring = mutation_operator(offspring, config_parameters_entity.mutation_rate["ALPHA"])
#     @info "Mutated offspring -> $(mutated_offspring)"

#     @test typeof(mutated_offspring) == Array{Float64,1}
#     @test eltype(mutated_offspring) == Float64
#     @test mutated_offspring != offspring
#     @test mutated_offspring[1] != offspring[1]

# end