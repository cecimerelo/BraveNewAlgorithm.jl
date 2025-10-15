using Distributions

function fertilising_room(population_model::PopulationModel)
    genes = generate_chromosome(population_model.range, population_model.config_parameters.chromosome_size)
    return Embryo(genes, population_model.fitness_function)
end

function generate_chromosome(range, chromosome_size)
    return rand(Uniform(range[1],range[2]), chromosome_size)
end

function multiple_fertilising_room(population_model::PopulationModel)
    population_size = population_model.config_parameters.population_size
    genes = rand(Uniform(population_model.range[1],population_model.range[2]),
                        population_model.config_parameters.chromosome_size, population_size)
    embryos = [Embryo(@view(genes[:,i]), population_model.fitness_function) for i in axes(genes,2)]
    return embryos
end
