using .BraveNewAlgorithm

using Test
using BlackBoxOptimizationBenchmarking

config_file_path = "./test/Config Files/config_file_1_test.json"
config_parameters_entity = read_parameters_file(config_file_path)
function_to_optimize = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
range = (-5.12, 5.12)
minimum_comparator = comparator(element, ff) = element >= ff.f_opt
fitness_function = FitnessFunction(function_to_optimize)
population_model = PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)
embryos = [
    fertilising_room(population_model)
    for _ in 1:population_model.config_parameters.population_size
]

mutated_chromosomes = [mutation_operator(embryo.chromosome, config_parameters_entity.mutation_rate["ALPHA"]) for embryo in embryos]

@testset "Test mutation_operator when called then different chromosome returned" begin
    for (embryo, mutated_chromosome) in zip(embryos, mutated_chromosomes)
        @test embryo.chromosome != mutated_chromosome
    end
end

# parents = (
#     Individual(embryos[1].chromosome, embryos[1].f_value, ALPHA()),
#     Individual(embryos[2].chromosome, embryos[2].f_value, ALPHA())
# )

# offspring = crossover_operator(parents, config_parameters_entity)
# @info "Offspring -> $(offspring)"
# @testset "Test mutation_operator when called then different chromosomes returned" begin
#     mutated_offspring = mutation_operator(offspring, config_parameters_entity.mutation_rate["ALPHA"])
#     @info "Mutated offspring -> $(mutated_offspring)"

#     @test typeof(mutated_offspring) == Array{Float64,1}
#     @test eltype(mutated_offspring) == Float64
#     @test mutated_offspring != offspring
#     @test mutated_offspring[1] != offspring[1]

# end