using Distributions

function fertilising_room(population_model::PopulationModel)
    genes = rand(Uniform(population_model.range[1],population_model.range[2]),
                        population_model.config_parameters.chromosome_size)
    embryo = Embryo(genes, population_model.fitness_function)
    return embryo
end

function multiple_fertilising_room(population_model::PopulationModel, population_size::Int)
    genes = rand(Uniform(population_model.range[1],population_model.range[2]),
                        population_model.config_parameters.chromosome_size, population_size)
    embryos = [Embryo(@view(genes[:,i]), population_model.fitness_function) for i in axes(genes,2)]
    return embryos
end
