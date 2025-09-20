using BlackBoxOptimizationBenchmarking

mutable struct FitnessFunction
    fitness_function::BBOBFunction
    calls_counter::Int64
    FitnessFunction(fitness_function::BBOBFunction, calls_counter::Int64=0) = new(fitness_function, calls_counter)
end

function (ff::FitnessFunction)( chromosome::Vector )
    ff.calls_counter += 1
    if ff.fitness_function.f(chromosome) < 0
        @warn "Values for 1,1 $(ff.fitness_function.f([1,1]))"
        @warn "Values for 0,0 $(ff.fitness_function.f([0,0]))"
        @warn "Using function $(ff.fitness_function)"
        @warn "Fitness function returned a negative value $(ff.fitness_function.f(chromosome))"
        @info "Chromosome -> $(chromosome), Fitness Function -> $(ff.fitness_function)"
    end
    return ff.fitness_function(chromosome)
end