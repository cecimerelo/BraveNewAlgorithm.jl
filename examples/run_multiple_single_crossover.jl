using Pkg
Pkg.activate(".")
include("./single_only_crossover.jl")

const NUMBER_OF_RUNS::Int = 30
const POPULATION_SIZE::Int = 400000

function run_multiple_times()
    println("Running single_only_crossover $NUMBER_OF_RUNS times with population size $POPULATION_SIZE")
    println("===")

    for i in 1:NUMBER_OF_RUNS
        println("=== Run $i ===")
        single_only_crossover(POPULATION_SIZE)
        println("===")
    end
end

@time run_multiple_times()
