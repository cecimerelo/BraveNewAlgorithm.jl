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


@testset "Test local_search when called then improved chromosome returned" begin
    number_of_passed_tests = 0
    total_tests = 100
    for _ in 1:total_tests
        new_chromosome = local_search(embryo.chromosome, population_model.fitness_function, population_model.config_parameters.mutation_rate[GAMMA().name], range)
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

@testset "Test local_search never returns a worse chromosome" begin
    for _ in 1:100
        new_chromosome = local_search(embryo.chromosome, population_model.fitness_function, population_model.config_parameters.mutation_rate[GAMMA().name], range)
        new_embryo = Embryo(new_chromosome, population_model.fitness_function)
        @info "Original fitness: $(embryo.f_value), new fitness: $(new_embryo.f_value)"
        @test new_embryo.f_value <= embryo.f_value
    end
end

@testset "Test local_search with max_steps = 1 still returns valid chromosome" begin
    new_chromosome = local_search(embryo.chromosome, population_model.fitness_function, population_model.config_parameters.mutation_rate[GAMMA().name], range, 1)
    @test typeof(new_chromosome) == Array{Float64,1}
    @test length(new_chromosome) == length(embryo.chromosome)
    new_embryo = Embryo(new_chromosome, population_model.fitness_function)
    @test new_embryo.f_value <= embryo.f_value
end

@testset "Test local_search with max_steps = 10 still returns valid chromosome" begin
    new_chromosome = local_search(embryo.chromosome, population_model.fitness_function, population_model.config_parameters.mutation_rate[GAMMA().name], range, 10)
    @test typeof(new_chromosome) == Array{Float64,1}
    @test length(new_chromosome) == length(embryo.chromosome)
    new_embryo = Embryo(new_chromosome, population_model.fitness_function)
    @test new_embryo.f_value <= embryo.f_value
end

@testset "Test local_search with max_steps = 100 still returns valid chromosome" begin
    new_chromosome = local_search(embryo.chromosome, population_model.fitness_function, population_model.config_parameters.mutation_rate[GAMMA().name], range, 100)
    @test typeof(new_chromosome) == Array{Float64,1}
    @test length(new_chromosome) == length(embryo.chromosome)
    new_embryo = Embryo(new_chromosome, population_model.fitness_function)
    @test new_embryo.f_value <= embryo.f_value
end

@testset "Test local_search with larger max_steps tends to find better or equal result than smaller max_steps" begin
    number_of_passed_tests = 0
    total_tests = 50
    for _ in 1:total_tests
        chromosome_short = local_search(embryo.chromosome, population_model.fitness_function, population_model.config_parameters.mutation_rate[GAMMA().name], range, 1)
        chromosome_long = local_search(embryo.chromosome, population_model.fitness_function, population_model.config_parameters.mutation_rate[GAMMA().name], range, 100)
        short_f = Embryo(chromosome_short, population_model.fitness_function).f_value
        long_f = Embryo(chromosome_long, population_model.fitness_function).f_value
        if long_f <= short_f
            number_of_passed_tests += 1
        end
    end
    @test number_of_passed_tests ≈ total_tests atol = 15
end