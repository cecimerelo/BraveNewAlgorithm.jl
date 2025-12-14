using .BraveNewAlgorithm
using Test

config_file_path = "./test/Config Files/config_file_1_test.json"
config_parameters_entity = read_parameters_file(config_file_path)
range = (-5.12, 5.12)
minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt
fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
population_model = PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)
embryos = [
    fertilising_room(population_model)
    for _ in 1:2
]

@testset "For a population with 2 members, test that the best is selected" begin
    @info "Embryos -> $(embryos)"
    pool = binary_tournament(embryos)
    @info "Pool -> $(pool)"

    @test length(pool) == 1
    if embryos[1].f_value < embryos[2].f_value
        @test pool[1].f_value == embryos[1].f_value
    else
        @test pool[1].f_value == embryos[2].f_value
    end
end