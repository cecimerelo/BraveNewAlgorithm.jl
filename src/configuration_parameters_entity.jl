const chromosome_size = "CHROMOSOME_SIZE"
const population_size = "POPULATION_SIZE"
const max_generations = "MAX_GENERATIONS"
const population_percentage = "POPULATION_PERCENTAGE"
const alpha = "ALPHA"
const beta = "BETA"
const gamma = "GAMMA"
const delta = "DELTA"
const epsilon = "EPSILON"
const mutation_rate = "MUTATION_RATE"

struct ConfigurationParametersEntity
    chromosome_size::Int
    population_size::Int
    max_generations::Int
    castes_percentages::Dict{String,Int}
    mutation_rate::Dict{String,Int}
end

function read_parameters_file(file_path::String)
    @info "Reading parameters file"
    config_parameters = JSON.parsefile(file_path)

    castes_percentages =
        Dict{String,Int}(
            alpha => config_parameters[population_percentage][alpha],
            beta => config_parameters[population_percentage][beta],
            gamma => config_parameters[population_percentage][gamma],
            delta => config_parameters[population_percentage][delta],
            epsilon => config_parameters[population_percentage][epsilon]
        )

    percentages =
        [
            percentage for (caste, percentage) in
            castes_percentages
        ]
    @assert(sum(percentages) == 100, "The percentages should have sum 100")

    if (castes_percentages[alpha]*config_parameters[population_size]/100 % 2 != 0
        || castes_percentages[beta]*config_parameters[population_size]/100 % 2 != 0)
        error("Percentage by population divided by 100 needs to be even")
    end

    generated_population = map!(x -> round(Int, x*config_parameters[population_size]/100), values(castes_percentages))
    if (sum(generated_population) != config_parameters[population_size])
        error("Generated population will not match population size")
    end

    castes_mr =
        Dict{String,Int}(
            alpha => config_parameters[mutation_rate][alpha],
            beta => config_parameters[mutation_rate][beta],
            gamma => config_parameters[mutation_rate][gamma],
            delta => config_parameters[mutation_rate][delta],
            epsilon => config_parameters[mutation_rate][epsilon]
        )

    return ConfigurationParametersEntity(
        config_parameters[chromosome_size], config_parameters[population_size],
        config_parameters[max_generations], castes_percentages, castes_mr)
end