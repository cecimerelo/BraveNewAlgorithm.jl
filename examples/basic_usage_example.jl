#!/usr/bin/env julia

"""
Basic Usage Example for BraveNewAlgorithm.jl

This script demonstrates how to use the BraveNewAlgorithm for optimization problems.
The algorithm is inspired by Aldous Huxley's "Brave New World" and uses a caste-based
population system to maintain exploration/exploitation balance.
"""

using Pkg
Pkg.activate(".")

# Load the BraveNewAlgorithm module
include("../src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm

# Load required dependencies
using BlackBoxOptimizationBenchmarking
using JSON

# Include utility functions
include("../src/utils.jl")
include("../src/commons.jl")

function main()
    println("=== BraveNewAlgorithm.jl Usage Example ===\n")

    # Example 1: Using a configuration file
    println("Example 1: Using a configuration file")
    example_with_config_file()

    println("\n" * "="^50 * "\n")

    # Example 2: Programmatic configuration
    println("Example 2: Programmatic configuration")
    example_with_programmatic_config()

    println("\n" * "="^50 * "\n")

    # Example 3: Custom fitness function
    println("Example 3: Custom fitness function")
    example_with_custom_fitness()
end

function example_with_config_file()
    """
    Example using a JSON configuration file (recommended for experiments)
    """
    println("Setting up the algorithm using a configuration file...")

    # Create a sample configuration file
    config = Dict(
        "CHROMOSOME_SIZE" => 5,
        "POPULATION_SIZE" => 30,
        "MAX_GENERATIONS" => 50,
        "POPULATION_PERCENTAGE" => Dict(
            "ALPHA" => 10,    # Elite individuals (10%)
            "BETA" => 20,     # High performers (20%)
            "GAMMA" => 20,    # Average performers (20%)
            "DELTA" => 20,    # Below average (20%)
            "EPSILON" => 30   # Low performers but high diversity (30%)
        ),
        "MUTATION_RATE" => Dict(
            "ALPHA" => 5,     # Low mutation for elite
            "BETA" => 8,      # Moderate mutation
            "GAMMA" => 10,    # Standard mutation
            "DELTA" => 12,    # Higher mutation
            "EPSILON" => 15   # Highest mutation for diversity
        )
    )

    # Save configuration to file
    config_file_path = "example_config.json"
    open(config_file_path, "w") do f
        JSON.print(f, config, 4)
    end
    println("Configuration saved to: $config_file_path")

    # Read configuration
    config_parameters = read_parameters_file(config_file_path)
    println("Configuration loaded successfully!")

    # Set up the optimization problem
    # Using BBOB function (Sphere function - simple quadratic function)
    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1], 0)

    # Define the search space range
    range = (-5.12, 5.12)

    # Define the comparator (when to stop optimization)
    # Stop when we reach the optimum (f_opt) or get close enough
    minimum_comparator = (element, fitness_function) -> element >= fitness_function.fitness_function.f_opt + 1e-8

    # Create the population model
    population_model = PopulationModel(
        config_parameters,
        fitness_function,
        range,
        minimum_comparator
    )

    println("Population model created with:")
    println("  - Chromosome size: $(config_parameters.chromosome_size)")
    println("  - Population size: $(config_parameters.population_size)")
    println("  - Max generations: $(config_parameters.max_generations)")
    println("  - Fitness function: $(fitness_function.fitness_function)")
    println("  - Search range: $range")

    # Run the algorithm
    println("\nRunning the Brave New Algorithm...")
    generation, results_df = brave_new_algorithm(population_model)

    # Display results
    println("\nOptimization completed!")
    println("Final generation: $generation")
    println("Total function evaluations: $(fitness_function.calls_counter)")

    if !isempty(results_df.F_Values)
        best_fitness = minimum(results_df.F_Values)
        println("Best fitness found: $best_fitness")
        println("Target fitness (f_opt): $(fitness_function.fitness_function.f_opt)")
        println("Difference from optimum: $(best_fitness - fitness_function.fitness_function.f_opt)")
    end

    # Clean up
    rm(config_file_path, force=true)

    return generation, results_df
end

function example_with_programmatic_config()
    """
    Example creating configuration parameters programmatically
    """
    println("Setting up the algorithm programmatically...")

    # Create configuration parameters directly
    castes_percentages = Dict{String, Int}(
        "ALPHA" => 15,
        "BETA" => 25,
        "GAMMA" => 25,
        "DELTA" => 20,
        "EPSILON" => 15
    )

    mutation_rates = Dict{String, Int}(
        "ALPHA" => 3,
        "BETA" => 6,
        "GAMMA" => 10,
        "DELTA" => 15,
        "EPSILON" => 20
    )

    config_parameters = ConfigurationParametersEntity(
        8,                    # chromosome_size
        40,                   # population_size
        100,                  # max_generations
        castes_percentages,   # castes_percentages
        mutation_rates        # mutation_rate
    )

    # Use a different BBOB function (Rosenbrock function)
    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[2], 0)
    range = (-5.0, 5.0)

    # More lenient stopping criterion
    minimum_comparator = (element, fitness_function) -> element >= fitness_function.fitness_function.f_opt + 1e-6

    population_model = PopulationModel(
        config_parameters,
        fitness_function,
        range,
        minimum_comparator
    )

    println("Running algorithm with Rosenbrock function...")
    generation, results_df = brave_new_algorithm(population_model)

    println("Optimization completed in $generation generations")
    println("Function evaluations: $(fitness_function.calls_counter)")

    if !isempty(results_df.F_Values)
        best_fitness = minimum(results_df.F_Values)
        println("Best fitness: $best_fitness")
    end

    return generation, results_df
end

function example_with_custom_fitness()
    """
    Example showing how to adapt the algorithm for custom optimization problems
    Note: This requires modifying the algorithm to work with custom functions
    """
    println("This example shows the structure for custom fitness functions...")
    println("(Note: Current implementation uses BBOB functions)")

    # For custom functions, you would need to create a wrapper that matches
    # the BBOB function interface, or modify the algorithm to accept custom functions

    println("To use custom fitness functions:")
    println("1. Create a function that takes a vector and returns a scalar")
    println("2. Wrap it in a structure compatible with the FitnessFunction type")
    println("3. Set appropriate f_opt value and range")

    # Example of what a custom function might look like:
    custom_function = x -> sum(x.^2)  # Simple sphere function
    println("Example custom function: f(x) = sum(x²)")
    println("For x = [1, 2, 3]: f(x) = $(custom_function([1, 2, 3]))")

    # For now, we'll use a BBOB function as demonstration
    println("\nRunning with BBOB Ellipsoid function as demonstration...")

    config_parameters = ConfigurationParametersEntity(
        6, 25, 30,
        Dict("ALPHA" => 20, "BETA" => 20, "GAMMA" => 20, "DELTA" => 20, "EPSILON" => 20),
        Dict("ALPHA" => 8, "BETA" => 10, "GAMMA" => 12, "DELTA" => 14, "EPSILON" => 16)
    )

    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[3], 0)
    range = (-5.0, 5.0)
    minimum_comparator = (element, fitness_function) -> element >= fitness_function.fitness_function.f_opt + 1e-5

    population_model = PopulationModel(config_parameters, fitness_function, range, minimum_comparator)

    generation, results_df = brave_new_algorithm(population_model)

    println("Custom function example completed in $generation generations")
    if !isempty(results_df.F_Values)
        println("Best fitness: $(minimum(results_df.F_Values))")
    end

    return generation, results_df
end

# Helper function to display algorithm information
function display_algorithm_info()
    println("=== About BraveNewAlgorithm.jl ===")
    println("This metaheuristic algorithm is inspired by Aldous Huxley's 'Brave New World'")
    println("and uses a caste-based population system to balance exploration and exploitation.")
    println("")
    println("Key Features:")
    println("- Five castes (ALPHA, BETA, GAMMA, DELTA, EPSILON) with different roles")
    println("- Adaptive mutation rates per caste")
    println("- Population percentages control diversity")
    println("- Built-in support for BBOB benchmark functions")
    println("- Returns detailed optimization statistics")
    println("")
end

# Run the examples if this script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    display_algorithm_info()
    main()
end