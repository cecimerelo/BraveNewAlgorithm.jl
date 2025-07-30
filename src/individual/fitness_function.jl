using BlackBoxOptimizationBenchmarking

mutable struct FitnessFunction
    fitness_function::BBOBFunction
    calls_counter::Int64
    FitnessFunction(fitness_function::BBOBFunction, calls_counter::Int64=0) = new(fitness_function, calls_counter)
    function call(self::FitnessFunction, chromosome::Array{Float64,1})
        self.calls_counter += 1
        return self.fitness_function(chromosome)
    end
end
