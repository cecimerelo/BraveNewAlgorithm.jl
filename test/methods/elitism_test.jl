using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking
using Test

@testset "Test elitism: best individual preserved when old best is better" begin
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

    # Selective elitism: only inject old best if it is better than new generation's best
    sort!(new_embryos_population, by=t -> t.f_value)
    new_best_before_elitism = new_embryos_population[1]
    if initial_best.f_value < new_best_before_elitism.f_value
        pop!(new_embryos_population)  # Remove worst (last element)
        best_embryo_copy = Embryo(collect(initial_best.chromosome), initial_best.f_value)
        insert_idx = searchsortedfirst(new_embryos_population, best_embryo_copy, by=t -> t.f_value)
        insert!(new_embryos_population, insert_idx, best_embryo_copy)
    end

    # Test 1: Population size is maintained
    @test length(new_embryos_population) == population_model.config_parameters.population_size

    # Test 2: Best fitness never degrades
    new_best = new_embryos_population[1]  # First element in sorted array
    @test new_best.f_value <= initial_best.f_value

    @info "New best f_value: $(new_best.f_value)"
end

@testset "Test selective elitism: old best NOT injected when new generation is better" begin
    config_file_path = "./test/Config Files/config_file_1_test.json"
    config_parameters_entity = read_parameters_file(config_file_path)
    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    range = (-5.12, 5.12)
    minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt + 1e-8
    population_model = PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)

    # Create a sorted new population
    embryos = [fertilising_room(population_model) for _ in 1:10]
    sort!(embryos, by=t -> t.f_value)

    # Simulate an "old best" that is worse than new generation's best
    worst_in_new = embryos[end]
    fake_old_best = Embryo(collect(worst_in_new.chromosome), worst_in_new.f_value)

    best_before = embryos[1].f_value
    initial_size = length(embryos)

    # Selective elitism: should NOT inject since fake_old_best is worse
    new_best_element = embryos[1]
    if fake_old_best.f_value < new_best_element.f_value
        pop!(embryos)
        best_embryo_copy = Embryo(collect(fake_old_best.chromosome), fake_old_best.f_value)
        insert_idx = searchsortedfirst(embryos, best_embryo_copy, by=t -> t.f_value)
        insert!(embryos, insert_idx, best_embryo_copy)
        new_best_element = embryos[1]
    end

    # Population size unchanged and best not degraded
    @test length(embryos) == initial_size
    @test embryos[1].f_value == best_before
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
        8,  # Number of hillclimbing steps
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
