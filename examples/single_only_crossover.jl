using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking

function single_only_crossover( population_size::Int )
    config_file_path = "./test/Config Files/config_file_1_test.json"
    config_parameters_entity = read_parameters_file(config_file_path)
    fitness_function = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
    range = (-5.12, 5.12)
    minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt
    ff = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    population_model = PopulationModel(config_parameters_entity, ff, range, minimum_comparator)
    embryos = [
        fertilising_room(population_model)
        for _ in 1:population_size
    ]

    @info typeof(embryos[1]), typeof(embryos[1].chromosome), typeof(embryos[1].f_value)
    @time all_offspring = get_offspring(embryos)

    @info "All offspring -> $(length(all_offspring))"
end
