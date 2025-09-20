#!/usr/bin/env julia

"""
Simple test to verify that the basic functionality works
This is a minimal test to ensure the algorithm can run
"""

using Pkg
Pkg.activate(".")

# Load the BraveNewAlgorithm module
include("../src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm

# Load required dependencies
using BlackBoxOptimizationBenchmarking

# Include utility functions
include("../src/utils.jl")
include("../src/commons.jl")

function simple_test()
    println("Testing BraveNewAlgorithm basic functionality...")

    try
        # Create minimal configuration
        config_parameters = ConfigurationParametersEntity(
            3,                    # chromosome_size (small for fast testing)
            200,                   # population_size (small for fast testing)
            10,                    # max_generations w/o change
            Dict{String, Int}(    # caste percentages
                "ALPHA" => 25,
                "BETA" => 50,
                "GAMMA" => 15,
                "DELTA" => 5,
                "EPSILON" => 5
            ),
            Dict{String, Int}(    # mutation rates
                "ALPHA" => 40,
                "BETA" => 40,
                "GAMMA" => 40,
                "DELTA" => 40,
                "EPSILON" => 40
            )
        )

        # Set up fitness function
        fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
        range = (-5.0, 5.0)
        @info "Fitness function: $(fitness_function.fitness_function)"
        @info "Fitness function optimal value: $(fitness_function.fitness_function.f_opt)"
        comparator = (element, ff) -> element >= ff.f_opt + 1e-6

        # Create population model
        population_model = PopulationModel(
            config_parameters,
            fitness_function,
            range,
            comparator
        )

        println("Running algorithm for $(config_parameters.max_generations) generations...")

        # Run algorithm
        generation, results = brave_new_algorithm(population_model)

        # Verify results
        @assert generation >= 0 "Generation should be non-negative"
        @assert !isempty(results.F_Values) "Results should contain fitness values"
        @assert length(results.F_Values) == length(results.Generations) "Generations and F_Values should have same length"

        best_fitness = minimum(results.F_Values)
        println("✅ Test passed!")
        println("   Completed generations: $generation")
        println("   Best fitness: $(round(best_fitness, digits=6))")
        println("   Target fitness: $(fitness_function.fitness_function.f_opt)")
        println("   Function evaluations: $(fitness_function.calls_counter)")

        return true

    catch e
        println("❌ Test failed with error:")
        println(e)
        return false
    end
end

# Run test if script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    success = simple_test()
    if success
        println("\n🎉 Algorithm is working correctly!")
    else
        println("\n💥 Algorithm test failed!")
        exit(1)
    end
end