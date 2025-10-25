using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking

using Test


for config_file in ["config_file_1_test.json", "config_file_3_test.json"]
    config_file_path = "./test/Config Files/$(config_file)"
    @info "Testing evolution for $(config_file)"
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
    best_element_fitness = best_element_of_population(embryos).f_value

    @testset "Test evolution when called then new population returned for $(config_file)" begin
        new_generation = evolution(population_in_castes, population_model)

        @test length(new_generation) == population_model.config_parameters.population_size
        for individual in new_generation
            @test typeof(individual) <: Vector{Float64}
        end

        new_embryos_population = [Embryo(chromosome, population_model.fitness_function) for chromosome in new_generation]
        population_in_castes = hatchery(population_model, new_embryos_population)

        @test population_in_castes[ALPHA()][end].f_value <= population_in_castes[BETA()][1].f_value
        @test population_in_castes[BETA()][end].f_value <= population_in_castes[DELTA()][1].f_value
        @test population_in_castes[DELTA()][end].f_value <= population_in_castes[EPSILON()][1].f_value
        @test population_in_castes[EPSILON()][end].f_value <= population_in_castes[GAMMA()][1].f_value

        new_best_element_fitness = best_element_of_population(new_embryos_population).f_value
        @test new_best_element_fitness <= best_element_fitness skip = true
    end
end
