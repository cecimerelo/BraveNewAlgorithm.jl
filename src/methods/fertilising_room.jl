using Distributions

function fertilising_room(population_model::PopulationModel)
    genes = rand(Uniform(population_model.range[1],population_model.range[2]),
                        population_model.config_parameters.chromosome_size)
    embryo = Embryo(genes, population_model.fitness_function)
    return embryo
end
