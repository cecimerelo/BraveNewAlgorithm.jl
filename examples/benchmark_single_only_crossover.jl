using Pkg
Pkg.activate(".")
include("../src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm

include("./single_only_crossover.jl")

using BenchmarkTools

const POPULATION_SIZE::Int = 400000

results = @benchmark single_only_crossover(POPULATION_SIZE)

display(results)