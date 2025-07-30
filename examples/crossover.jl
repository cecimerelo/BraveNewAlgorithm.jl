using Pkg
Pkg.activate(".")
include("../src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking

include("../src/utils.jl")
include("../src/operators/crossover.jl")
include("../src/methods/fertilising_room.jl")

const POPULATION_SIZE = 40000

config_file_path = "./test/Config Files/config_file_1_test.json"
config_parameters_entity = read_parameters_file(config_file_path)
fitness_function = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
range = (-5.12, 5.12)
minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt
ff = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
population_model = PopulationModel(config_parameters_entity, ff, range, minimum_comparator)
embryos = [
    fertilising_room(population_model)
    for _ in 1:POPULATION_SIZE
]

all_offspring = []
for i in 1:2:length(embryos)-1
    j = i + 1
    parents = (
        Individual(embryos[i].chromosome, embryos[i].f_value, ALPHA()),
        Individual(embryos[j].chromosome, embryos[j].f_value, ALPHA())
    )

    offspring = crossover_operator(parents)
    push!(all_offspring, offspring[1])
    push!(all_offspring, offspring[2])
end

@info "All offspring -> $(length(all_offspring))"
