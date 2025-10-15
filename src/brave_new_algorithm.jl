include("methods/hatchery.jl")
include("methods/evolution.jl")
include("methods/fertilising_room.jl")
include("commons.jl")

using DataFrames
using InformationMeasures

function brave_new_algorithm(population_model::PopulationModel)
    generations_array = Array{Int,1}()
    best_f_values = Array{Float64,1}()
    entropies = Array{Float64,1}()
    edit_distances = Array{Float64,1}()

    @info """
    Creating embryos,
                Chromosome Size -> $(population_model.config_parameters.chromosome_size)
    """
    embryos = multiple_fertilising_room(population_model, population_model.config_parameters.population_size )
    best_element = best_element_of_population(embryos)

    generation = 0
    generations_with_the_same_best_element = 0

    while population_model.comparator(best_element.f_value, population_model.fitness_function.fitness_function) &&
        generations_with_the_same_best_element <= population_model.config_parameters.max_generations

        @info "Generation -> $(generation), Best f_value -> $(best_element.f_value)"
        @info "Generations with the same best element -> $(generations_with_the_same_best_element)"

        population_in_castes = hatchery(population_model, embryos)
        new_chromosomes = evolution(population_in_castes, population_model)
        new_embryos_population = [Embryo(chromosome, population_model.fitness_function) for chromosome in new_chromosomes]
        new_best_element = best_element_of_population(new_embryos_population)

        if new_best_element.f_value >= best_element.f_value
            generations_with_the_same_best_element = generations_with_the_same_best_element + 1
            @warn "Best element has not improved"
        else
            generations_with_the_same_best_element = 0
            best_element = new_best_element
        end

        all_f_values = [embryo.f_value for embryo in embryos]
        entropy = get_entropy(all_f_values)
        all_chromosomes = [embryo.chromosome for embryo in embryos]
        edit_distance = calculate_edit_distance(
                            all_chromosomes, best_element.chromosome,
                            population_model.config_parameters.population_size
                        )
        push!(generations_array, generation)
        push!(best_f_values, best_element.f_value)
        push!(entropies, entropy)
        push!(edit_distances, edit_distance)

        embryos = new_embryos_population
        generation = generation + 1
    end

    dict_population = Dict(
            "Generations" => generations_array,
            "F_Values" => best_f_values,
            "Entropy" => entropies,
            "Edit_distance" => edit_distances
    )

    return (generation, DataFrame(dict_population))
end
