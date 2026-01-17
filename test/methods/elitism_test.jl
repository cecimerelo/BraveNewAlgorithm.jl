using Pkg
Pkg.activate(".")

include("../../src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking
using Test

@testset "Test elitism: best individual preserved across generations" begin
    # Setup with simple configuration
    config_file_path = "./test/Config Files/config_file_1_test.json"
    config_parameters_entity = read_parameters_file(config_file_path)
    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    range = (-5.12, 5.12)
    minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt + 1e-8
    population_model = PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)
    
    # Create initial population
    embryos = [
        fertilising_room(population_model)
        for _ in 1:population_model.config_parameters.population_size
    ]
    
    initial_best = best_element_of_population(embryos)
    @info "Initial best f_value: $(initial_best.f_value)"
    
    # Evolve one generation
    population_in_castes = hatchery(population_model, embryos)
    new_chromosomes = evolution(population_in_castes, population_model)
    new_embryos_population = [Embryo(chromosome, population_model.fitness_function) for chromosome in new_chromosomes]
    
    # Apply elitism: sort, remove worst, insert best
    sort!(new_embryos_population, by=t -> t.f_value)
    pop!(new_embryos_population)  # Remove worst (last element)
    best_embryo_copy = Embryo(collect(initial_best.chromosome), initial_best.f_value)
    insert_idx = searchsortedfirst(new_embryos_population, best_embryo_copy, by=t -> t.f_value)
    insert!(new_embryos_population, insert_idx, best_embryo_copy)
    
    # Test 1: Population size is maintained
    @test length(new_embryos_population) == population_model.config_parameters.population_size
    
    # Test 2: Best individual from previous generation is present
    best_chromosomes_match = any(e -> e.chromosome == initial_best.chromosome, new_embryos_population)
    @test best_chromosomes_match == true
    
    # Test 3: Best fitness never degrades
    new_best = new_embryos_population[1]  # First element in sorted array
    @test new_best.f_value <= initial_best.f_value
    
    @info "New best f_value: $(new_best.f_value)"
    @info "Best individual preserved: $best_chromosomes_match"
end

@testset "Test elitism: sorted population properties" begin
    config_file_path = "./test/Config Files/config_file_1_test.json"
    config_parameters_entity = read_parameters_file(config_file_path)
    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    range = (-5.12, 5.12)
    minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt + 1e-8
    population_model = PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)
    
    # Create population
    embryos = [
        fertilising_room(population_model)
        for _ in 1:10
    ]
    
    # Sort the population
    sort!(embryos, by=t -> t.f_value)
    
    best = embryos[1]
    worst = embryos[end]
    
    # Test: worst should have highest f_value (for minimization)
    @test worst.f_value >= best.f_value
    
    # Test: worst should be the maximum
    all_f_values = [e.f_value for e in embryos]
    @test worst.f_value == maximum(all_f_values)
    
    # Test: best should be the minimum
    @test best.f_value == minimum(all_f_values)
end

@testset "Test elitism through multiple generations with brave_new_algorithm" begin
    # Setup with limited generations for fast testing
    config_parameters = ConfigurationParametersEntity(
        10, # Larger chromosome size to accommodate mutation rates
        20, # Small population
        5,  # Few generations
        Dict{String, Int}(
            "ALPHA" => 10,  # Must be half of BETA (10 = 20/2)
            "BETA" => 20,   # Must be double ALPHA
            "GAMMA" => 30,
            "DELTA" => 20,
            "EPSILON" => 20  # Adjusted to sum to 100
        ),
        Dict{String, Int}(
            "ALPHA" => 5,
            "BETA" => 8,
            "GAMMA" => 12,
            "DELTA" => 15,
            "EPSILON" => 20
        )
    )
    
    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    range = (-5.12, 5.12)
    minimum_comparator = (element, ff) -> element >= ff.f_opt
    population_model = PopulationModel(config_parameters, fitness_function, range, minimum_comparator)
    
    # Run algorithm
    final_generation, results = brave_new_algorithm(population_model)
    
    # Test: Best fitness should never increase (degrade) across generations
    best_f_values = results.F_Values
    for i in 2:length(best_f_values)
        @test best_f_values[i] <= best_f_values[i-1]
    end
    
    @info "Generations completed: $(final_generation)"
    @info "Best fitness values: $(best_f_values)"
end
