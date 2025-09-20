using .BraveNewAlgorithm

using Test
using BlackBoxOptimizationBenchmarking

POPULATION_SIZE_MISMATCHED = "The population divided in castes does not match the length of the initial population"

config_file_path = "./test/Config Files/config_file_1_test.json"
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
population_in_castes = hatchery(population_model, embryos)
# show f_values of every member of the population
for (caste, population) in population_in_castes
    println("Caste: $(caste.name)")
    for individual in population
        println("   $(individual.f_value)")
    end
end

@testset "Test hatchery when called then returns population divided in castes" begin
    @testset "Test when percentages sum 100" begin
        for caste in [ALPHA(), BETA(), GAMMA(), DELTA(), EPSILON()]
            @test haskey(population_in_castes, caste)
        end

        castes_length = [length(population) for (caste, population) in population_in_castes]
        total_length = sum(castes_length)
        @test total_length == config_parameters_entity.population_size
    end

    @testset "Test population size is asserted correctly" begin
        embryos = [
            fertilising_room(population_model)
            for _ in 1:population_model.config_parameters.population_size
        ]
        castes = Dict("ALPHA" => [embryos[1], embryos[2]])
        @test_throws AssertionError(POPULATION_SIZE_MISMATCHED) assert_population_divided_in_castes_match_initial_population_size(castes, 10)
    end

    @testset "Test that the fitness value of the embryos is in descending order by castes" begin
        for (caste, population) in population_in_castes
            @test population[1].f_value <= population[end].f_value
        end
        @test population_in_castes[ALPHA()][end].f_value <= population_in_castes[BETA()][1].f_value
        @test population_in_castes[BETA()][end].f_value <= population_in_castes[DELTA()][1].f_value
        @test population_in_castes[DELTA()][end].f_value <= population_in_castes[EPSILON()][1].f_value
        @test population_in_castes[EPSILON()][end].f_value <= population_in_castes[GAMMA()][1].f_value
    end
end
