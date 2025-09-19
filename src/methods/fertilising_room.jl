using Distributions

function fertilising_room(population_model::PopulationModel)
    genes = generate_chromosome(population_model.range, population_model.config_parameters.chromosome_size)
    return Embryo(genes, population_model.fitness_function)
end

function generate_chromosome(range, chromosome_size)
    return rand(Uniform(range[1],range[2]), chromosome_size)
end
