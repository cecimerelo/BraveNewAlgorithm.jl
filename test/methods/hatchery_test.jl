using .BraveNewAlgorithm

include("../../src/methods/hatchery.jl")
include("../../src/brave_new_algorithm.jl")
include("../../src/commons.jl")
include("../../src/utils.jl")
include("../../src/methods/fertilising_room.jl")


using Test

POPULATION_SIZE_MISMATCHED = "The population divided in castes does not match the length of the initial population"

function run_hatchery(config_file_path)
    config_parameters_entity = read_parameters_file(config_file_path)
    fitness_function = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
    range = (-5.12, 5.12)
    minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt
    fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    population_model = PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)
    embryos = [
        fertilising_room(population_model)
        for _ in 1:population_model.config_parameters.population_size
    ]
    castes = hatchery(population_model, embryos)
    return castes
end

@testset "Test hatchery when called then returns population divided in castes" begin
    @testset "Test when percentages sum 100" begin
        config_file_path = "../test/Config Files/config_file_1_test.json"
        population_in_castes = run_hatchery(config_file_path)
        castes = keys(population_in_castes)

        @test ALPHA() in castes
        @test BETA() in castes
        @test GAMMA() in castes
        @test DELTA() in castes
        @test EPSILON() in castes

        castes_length = [length(population) for (caste, population) in population_in_castes]
        total_length = sum(castes_length)
        config_parameters_entity = read_parameters_file(config_file_path)
        @test total_length == config_parameters_entity.population_size
    end

    @testset "Test population size is asserted correctly" begin
        config_file_path = "../test/Config Files/config_file_1_test.json"
        config_parameters_entity = read_parameters_file(config_file_path)
        fitness_function = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
        range = (-5.12, 5.12)
        minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt
        fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
        population_model = PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)
        embryos = [
            fertilising_room(population_model)
            for _ in 1:population_model.config_parameters.population_size
        ]
        castes = Dict("ALPHA" => [embryos[1], embryos[2]])
        @test_throws AssertionError(POPULATION_SIZE_MISMATCHED) assert_population_divided_in_castes_match_initial_population_size(castes, 10)
    end
end