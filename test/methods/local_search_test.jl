using .BraveNewAlgorithm

using Test
using BlackBoxOptimizationBenchmarking

config_file_path = "./test/Config Files/config_file_1_test.json"
config_parameters_entity = read_parameters_file(config_file_path)
range = (-5.12, 5.12)
minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt
fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
population_model = PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)
embryo = fertilising_room(population_model)


@testset "Test local_search when called for GAMMA then improved chromosome returned" begin
    number_of_passed_tests = 0
    total_tests = 100
    for _ in 1:total_tests
        new_chromosome = local_search(embryo.chromosome, population_model.fitness_function, population_model.config_parameters.mutation_rate[GAMMA().name], range,GAMMA())
        @test typeof(new_chromosome) == Array{Float64,1}
        @test length(new_chromosome) == length(embryo.chromosome)
        @test population_model.fitness_function.calls_counter > 0
        new_embryo = Embryo(new_chromosome, population_model.fitness_function)
        if new_embryo.f_value < embryo.f_value
            number_of_passed_tests += 1
        end
    end
    @test number_of_passed_tests ≈ total_tests atol = 20
end

@testset "Test local_search when called for not GAMMA then same chromosome returned" begin
    new_chromosome = local_search(
        embryo.chromosome,
        population_model.fitness_function,
        population_model.config_parameters.mutation_rate[ALPHA().name],
        range,
        ALPHA()
    )
    @test new_chromosome == embryo.chromosome
end