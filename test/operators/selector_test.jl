using .BraveNewAlgorithm

using BlackBoxOptimizationBenchmarking
using Test

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

castes = hatchery(population_model, embryos)

@testset "Test selector_operator when called then reproduction pool is returned" begin
    @testset "Test selector_operator for ALPHA caste" begin
        reproduction_pool = selector_operator(ALPHA(), castes[ALPHA()])

        @test typeof(reproduction_pool) <: Vector{Tuple}
        @test typeof(reproduction_pool[1]) <: Tuple{Individual, Individual}
        @test typeof(reproduction_pool[1][1]) <: Individual

        total_length = [length(tuple) for tuple in reproduction_pool]
        sum_total_length = sum(total_length)
        @test sum_total_length == length(castes[ALPHA()])
    end

    @testset "Test selector_operator for BETA caste" begin
        reproduction_pool = selector_operator(ALPHA(), castes[ALPHA()])
        beta_reproduction_pool = selector_operator(BETA(), castes[BETA()], reproduction_pool)

        @test typeof(beta_reproduction_pool) <: Vector{Tuple}
        @test beta_reproduction_pool[1][1].caste == ALPHA()
        @test beta_reproduction_pool[1][2].caste == BETA()

        total_length = [length(tuple) for tuple in reproduction_pool]
        sum_total_length = sum(total_length)
        @test sum_total_length == length(castes[ALPHA()])
        beta_population_proportion = config_parameters_entity.castes_percentages["BETA"] / config_parameters_entity.castes_percentages["ALPHA"]
        @test sum_total_length * beta_population_proportion == length(castes[BETA()])
    end

    @testset "Test selector_operator for lower castes" begin
        @test_logs (:info,"Lower caste, selection not applied") selector_operator(GAMMA(), castes[GAMMA()])
        @test_logs (:info,"Lower caste, selection not applied") selector_operator(DELTA(), castes[DELTA()])
        @test_logs (:info,"Lower caste, selection not applied") selector_operator(EPSILON(), castes[EPSILON()])
    end

end
