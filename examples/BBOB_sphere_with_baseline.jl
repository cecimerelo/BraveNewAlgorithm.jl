#!/usr/bin/env julia

"""
Script used for experiments
"""

using Pkg
Pkg.activate(".")

include("../src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm

using BlackBoxOptimizationBenchmarking

function simple_test(problem_dimensions, population_size, max_generations, alpha_percentage, baseline=false)
    println("Testing BraveNewAlgorithm basic functionality...")

    try
        config_parameters = ConfigurationParametersEntity(
            problem_dimensions,
            population_size,
            max_generations,
            Dict{String, Int}(
                "ALPHA" => alpha_percentage,
                "BETA" => alpha_percentage*2,
                "GAMMA" => 90-alpha_percentage*3,
                "DELTA" => 5,
                "EPSILON" => 5
            ),
            Dict{String, Int}(
                "ALPHA" => 40,
                "BETA" => 40,
                "GAMMA" => 40,
                "DELTA" => 40,
                "EPSILON" => 40
            )
        )

        fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
        range = (-5.0, 5.0)
        @info "Fitness function: $(fitness_function.fitness_function)"
        @info "Fitness function optimal value: $(fitness_function.fitness_function.f_opt)"
        comparator = (element, ff) -> element >= ff.f_opt + 1e-6

        population_model = PopulationModel(
            config_parameters,
            fitness_function,
            range,
            comparator
        )

        if baseline
            println("Running baseline for $(population_size) individuals and $(problem_dimensions) dimension...")
            embryos = multiple_fertilising_room(population_model)
            best_element = best_element_of_population(embryos)
            println("✅ Baseline run!")
            println("   Best fitness: $(round(best_element.f_value, digits=6))")
        else
            println("Running algorithm for $(config_parameters.max_generations) generations...")
            generation, results = brave_new_algorithm(population_model)

            @assert generation >= 0 "Generation should be non-negative"
            @assert !isempty(results.F_Values) "Results should contain fitness values"
            @assert length(results.F_Values) == length(results.Generations) "Generations and F_Values should have same length"

            best_fitness = minimum(results.F_Values)
            println("✅ Run algorithm!")
            println("   Completed generations: $generation")
            println("   Best fitness: $(round(best_fitness, digits=6))")
            println("   Target fitness: $(fitness_function.fitness_function.f_opt)")
            println("   Function evaluations: $(fitness_function.calls_counter)")
        end

        return true

    catch e
        println("❌ Test failed with error:")
        println(e)
        return false
    end
end

(@main)(ARGS) = if abspath(PROGRAM_FILE) == @__FILE__
    problem_dimensions = length(ARGS) > 0 ? parse(Int, ARGS[1]) : 3
    population_size = length(ARGS) > 1 ? parse(Int, ARGS[2]) : 200
    max_generations = length(ARGS) > 2 ? parse(Int, ARGS[3]) : 10
    alpha_percentage = length(ARGS) > 3 ? parse(Int, ARGS[4]) : 25
    baseline = length(ARGS) > 4 ? true : false
    success = simple_test(problem_dimensions, population_size, max_generations, alpha_percentage, baseline)
    if success
        println("\n🎉 Algorithm is working correctly!")
    else
        println("\n💥 Algorithm test failed!")
        exit(1)
    end
end
