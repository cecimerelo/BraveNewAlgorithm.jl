include("methods/hatchery.jl")
include("methods/evolution.jl")
include("methods/fertilising_room.jl")

using DataFrames

function brave_new_algorithm(population_model::PopulationModel)
    generations_array = Array{Int,1}()
    best_f_values = Array{Float64,1}()

    @info """
    Creating embryos,
                Chromosome Size -> $(population_model.config_parameters.chromosome_size)
    """
    embryos = multiple_fertilising_room(population_model)
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

        # Sort the population once - this will be reused by hatchery in next iteration
        sort!(new_embryos_population, by=t -> t.f_value)

        # Selective elitism: only inject the best individual from the previous generation
        # if it is better than the best of the new generation
        new_best_element = new_embryos_population[1]
        if best_element.f_value < new_best_element.f_value
            pop!(new_embryos_population)  # Remove worst (last element)
            best_embryo_copy = Embryo(collect(best_element.chromosome), best_element.f_value)
            insert_idx = searchsortedfirst(new_embryos_population, best_embryo_copy, by=t -> t.f_value)
            insert!(new_embryos_population, insert_idx, best_embryo_copy)
            # After injection new_embryos_population[1] is the preserved old best
        end
        # new_best_element is always new_embryos_population[1]: either the new generation's best
        # (when no elitism fires) or the injected old best (when elitism fires)
        new_best_element = new_embryos_population[1]

        if new_best_element.f_value >= best_element.f_value
            generations_with_the_same_best_element = generations_with_the_same_best_element + 1
            @warn "Best element has not improved"
        else
            generations_with_the_same_best_element = 0
            best_element = new_best_element
        end

        push!(generations_array, generation)
        push!(best_f_values, best_element.f_value)

        embryos = new_embryos_population
        generation = generation + 1
    end

    dict_population = Dict(
            "Generations" => generations_array,
            "F_Values" => best_f_values
    )

    return (generation, DataFrame(dict_population))
end
