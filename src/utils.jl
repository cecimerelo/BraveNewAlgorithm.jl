using JSON
using CSV
using Dates
using Distances


function write_entry_to_summary(
        evaluations,
        time,
        outcome_file_name,
        fitness_function,
        config_file,
        last_generation,
        best_element,
    )
    summary_path = "./data/Outcomes/summary.csv"
    summary_df = CSV.File(summary_path) |> DataFrame
    df_line = DataFrame(
        TIME = time,
        F_EVALUATIONS = evaluations,
        FUNCTION = "$(fitness_function)",
        CONFIG_FILE_PATH = config_file,
        OUTCOME_FILE = outcome_file_name,
        GENERATION = last_generation,
        BEST_ELEMENT = best_element,
        F_OPT = fitness_function.f_opt
    )

    append!(summary_df, df_line)
    CSV.write(summary_path, summary_df)
end

function write_results_to_file(config_file, fitness_function, population)
    outcome_file_name = "$(config_file)_$(fitness_function.fitness_function)"
    outcome_path = "./data/Outcomes/$(outcome_file_name)"
    time = Dates.format(now(), "HH:MM:SS")
    name = "$(outcome_path)_$(time).csv"
    CSV.write(name, population)

    return name
end

function calculate_edit_distance(all_chromosomes, best_chromosome, population_size)
    distances = Array{Float64, 1}()

    for chromosome in all_chromosomes
        distance = euclidean(chromosome, best_chromosome)
        push!(distances, distance)
    end

    return sum(distances) / population_size
end
