#!/usr/bin/env julia

"""
Elitism Example for BraveNewAlgorithm.jl

This example demonstrates the elitism feature where the best individual
from each generation is preserved in the next generation.
"""

using Pkg
Pkg.activate(".")

include("../src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking
include("../src/utils.jl")
include("../src/commons.jl")

function elitism_demonstration()
    println("=" ^ 60)
    println("🧬 Elitism Feature Demonstration")
    println("=" ^ 60)
    println("This example shows that the best individual from each")
    println("generation is always preserved in the next generation,")
    println("ensuring that the best fitness never degrades.")
    println("=" ^ 60)
    
    # Configuration with reasonable parameters
    config_parameters = ConfigurationParametersEntity(
        5,                    # chromosome_size (5 dimensions)
        40,                   # population_size (40 individuals - must satisfy ALPHA/BETA even constraint)
        20,                   # max_generations (20 generations max)
        Dict{String, Int}(    # population percentages by caste
            "ALPHA" => 10,    # Elite: 10% (must be half of BETA) = 4 individuals (even)
            "BETA" => 20,     # Good: 20% (must be double ALPHA) = 8 individuals (even)
            "GAMMA" => 30,    # Average: 30%
            "DELTA" => 20,    # Below average: 20%
            "EPSILON" => 20   # Diverse/exploratory: 20%
        ),
        Dict{String, Int}(    # mutation rates by caste
            "ALPHA" => 5,     # Low mutation for elite
            "BETA" => 8,      
            "GAMMA" => 12,    
            "DELTA" => 15,    
            "EPSILON" => 20   # High mutation for exploration
        )
    )
    
    # Set up the fitness function (BBOB Sphere function)
    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    
    # Define search space and stopping criterion
    search_range = (-5.12, 5.12)
    stop_when_optimal = (element, ff) -> element >= ff.f_opt + 1e-8
    
    # Create the population model
    population_model = PopulationModel(
        config_parameters,
        fitness_function,
        search_range,
        stop_when_optimal
    )
    
    println("\n📋 Configuration:")
    println("  - Problem dimensions: $(config_parameters.chromosome_size)")
    println("  - Population size: $(config_parameters.population_size)")
    println("  - Max generations: $(config_parameters.max_generations)")
    println("  - Fitness function: Sphere (minimize Σx²)")
    println("  - Search range: $search_range")
    
    println("\n🚀 Starting optimization with elitism enabled...")
    println("=" ^ 60)
    
    start_time = time()
    final_generation, results = brave_new_algorithm(population_model)
    elapsed_time = time() - start_time
    
    println("\n" * "=" ^ 60)
    println("✅ Optimization completed!")
    println("=" ^ 60)
    println("📊 Results:")
    println("  - Generations run: $final_generation")
    println("  - Time elapsed: $(round(elapsed_time, digits=2)) seconds")
    println("  - Function evaluations: $(fitness_function.calls_counter)")
    
    if !isempty(results.F_Values)
        best_fitness = minimum(results.F_Values)
        target_fitness = fitness_function.fitness_function.f_opt
        
        println("\n🎯 Best Solution:")
        println("  - Best fitness: $(round(best_fitness, digits=8))")
        println("  - Target (f_opt): $(round(target_fitness, digits=8))")
        println("  - Gap to optimum: $(round(best_fitness - target_fitness, digits=8))")
        
        # Verify elitism: fitness should never increase (degrade)
        println("\n🔍 Elitism Verification:")
        println("  Checking that best fitness never degrades across generations...")
        
        fitness_never_degrades = true
        for i in 2:length(results.F_Values)
            if results.F_Values[i] > results.F_Values[i-1]
                fitness_never_degrades = false
                println("  ❌ ERROR: Fitness degraded at generation $(results.Generations[i])")
                println("     From $(results.F_Values[i-1]) to $(results.F_Values[i])")
                break
            end
        end
        
        if fitness_never_degrades
            println("  ✅ SUCCESS: Best fitness never degraded!")
            println("     Elitism is working correctly.")
        end
        
        # Show convergence progress
        println("\n📈 Convergence Progress:")
        num_shown = min(10, length(results.F_Values))
        println("  (showing first and last $num_shown generations)")
        
        # Show first few generations
        println("\n  First generations:")
        for i in 1:min(5, length(results.F_Values))
            gen = results.Generations[i]
            fitness = results.F_Values[i]
            improvement = i == 1 ? "N/A" : string(round(results.F_Values[i-1] - fitness, digits=6))
            println("    Gen $gen: fitness = $(round(fitness, digits=6)), improvement = $improvement")
        end
        
        # Show last few generations
        if length(results.F_Values) > 5
            println("\n  Last generations:")
            for i in max(1, length(results.F_Values)-4):length(results.F_Values)
                gen = results.Generations[i]
                fitness = results.F_Values[i]
                improvement = i == 1 ? "N/A" : string(round(results.F_Values[i-1] - fitness, digits=6))
                println("    Gen $gen: fitness = $(round(fitness, digits=6)), improvement = $improvement")
            end
        end
        
        # Calculate improvement statistics
        total_improvement = results.F_Values[1] - results.F_Values[end]
        avg_improvement_per_gen = total_improvement / length(results.F_Values)
        
        println("\n📊 Statistics:")
        println("  - Total improvement: $(round(total_improvement, digits=6))")
        println("  - Avg improvement per generation: $(round(avg_improvement_per_gen, digits=6))")
        println("  - Convergence rate: $(round((1 - results.F_Values[end]/results.F_Values[1]) * 100, digits=2))%")
    end
    
    println("\n" * "=" ^ 60)
    println("🎓 Key Takeaways:")
    println("  1. The best individual is always preserved across generations")
    println("  2. This ensures monotonic improvement (fitness never degrades)")
    println("  3. Elitism balances exploitation and exploration effectively")
    println("=" ^ 60)
    
    return final_generation, results
end

# Run the demonstration
if abspath(PROGRAM_FILE) == @__FILE__
    elitism_demonstration()
end
