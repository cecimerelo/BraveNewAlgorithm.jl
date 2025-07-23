#!/usr/bin/env julia

"""
Quick Start Example for BraveNewAlgorithm.jl

This is a minimal example showing how to get started with the algorithm.
Run this script to see the algorithm in action!

If you get dependency errors, first run: julia examples/setup.jl
"""

using Pkg
Pkg.activate(".")

# Check if dependencies are installed
try
    # Load the BraveNewAlgorithm module
    include("../src/BraveNewAlgorithm.jl")
    using .BraveNewAlgorithm

    # Load required dependencies
    using BlackBoxOptimizationBenchmarking
    using JSON

    # Include utility functions
    include("../src/utils.jl")
    include("../src/commons.jl")
catch e
    println("❌ Dependencies not properly installed!")
    println("Please run: julia examples/setup.jl")
    println("\nError details: $e")
    exit(1)
end

function quickstart_example()
    println("🧬 Quick Start: BraveNewAlgorithm.jl")
    println("Optimizing the Sphere function f(x) = Σx²")
    println("-" ^ 40)
    
    # 1. Create configuration parameters
    config_parameters = ConfigurationParametersEntity(
        5,                    # chromosome_size (5 dimensions)
        20,                   # population_size (20 individuals)
        50,                   # max_generations (50 generations max)
        Dict{String, Int}(    # population percentages by caste
            "ALPHA" => 10,    # Elite: 10%
            "BETA" => 20,     # Good: 20%
            "GAMMA" => 30,    # Average: 30%
            "DELTA" => 25,    # Below average: 25%
            "EPSILON" => 15   # Diverse/exploratory: 15%
        ),
        Dict{String, Int}(    # mutation rates by caste
            "ALPHA" => 5,     # Low mutation for elite
            "BETA" => 8,      
            "GAMMA" => 12,    
            "DELTA" => 15,    
            "EPSILON" => 20   # High mutation for exploration
        )
    )
    
    # 2. Set up the fitness function (BBOB Sphere function)
    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1], 0)
    
    # 3. Define search space and stopping criterion
    search_range = (-5.12, 5.12)
    stop_when_optimal = (element, ff) -> element >= ff.fitness_function.f_opt + 1e-8
    
    # 4. Create the population model
    population_model = PopulationModel(
        config_parameters,
        fitness_function,
        search_range,
        stop_when_optimal
    )
    
    # 5. Run the algorithm
    println("Starting optimization...")
    start_time = time()
    
    final_generation, results = brave_new_algorithm(population_model)
    
    elapsed_time = time() - start_time
    
    # 6. Display results
    println("\n✅ Optimization completed!")
    println("   Generations: $final_generation")
    println("   Time: $(round(elapsed_time, digits=2)) seconds")
    println("   Function evaluations: $(fitness_function.calls_counter)")
    
    if !isempty(results.F_Values)
        best_fitness = minimum(results.F_Values)
        target_fitness = fitness_function.fitness_function.f_opt
        
        println("   Best fitness: $(round(best_fitness, digits=8))")
        println("   Target (f_opt): $(round(target_fitness, digits=8))")
        println("   Gap to optimum: $(round(best_fitness - target_fitness, digits=8))")
        
        # Show convergence progress
        if length(results.F_Values) >= 5
            println("\n📈 Convergence progress (last 5 generations):")
            for i in max(1, length(results.F_Values)-4):length(results.F_Values)
                gen = results.Generations[i]
                fitness = results.F_Values[i]
                println("   Generation $gen: $(round(fitness, digits=6))")
            end
        end
    end
    
    return final_generation, results
end

# Run the quickstart example
if abspath(PROGRAM_FILE) == @__FILE__
    quickstart_example()
end