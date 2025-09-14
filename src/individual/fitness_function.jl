using BlackBoxOptimizationBenchmarking

mutable struct FitnessFunction
    fitness_function::BBOBFunction
    calls_counter::Int64
    FitnessFunction(fitness_function::BBOBFunction, calls_counter::Int64=0) = new(fitness_function, calls_counter)

end

function (ff::FitnessFunction)( chromosome::AbstractArray )
    ff.calls_counter += 1
    return ff.fitness_function(chromosome)
end