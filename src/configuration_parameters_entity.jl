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
    
    # Inner constructor with validation
    function ConfigurationParametersEntity(
        chromosome_size::Int,
        population_size::Int,
        max_generations::Int,
        castes_percentages::Dict{String,Int},
        mutation_rate::Dict{String,Int}
    )
        # Validate that all required castes are present
        required_castes = [alpha, beta, gamma, delta, epsilon]
        for caste in required_castes
            if !haskey(castes_percentages, caste)
                error("Missing required caste: $caste")
            end
            if !haskey(mutation_rate, caste)
                error("Missing mutation rate for caste: $caste")
            end
        end
        
        # Validate alpha population should be less than beta population
        if castes_percentages[alpha] >= castes_percentages[beta]
            error("Alpha population should be < Beta population")
        end
        
        # Validate percentages sum to 100
        total_percentage = sum(values(castes_percentages))
        if total_percentage != 100
            error("The percentages should add up to 100, got $total_percentage")
        end
        
        # Validate percentage by population divided by 100 needs to be even for ALPHA and BETA
        if (castes_percentages[alpha] * population_size / 100) % 2 != 0
            error("Percentage by population divided by 100 needs to be even for ALPHA caste")
        end
        if (castes_percentages[beta] * population_size / 100) % 2 != 0
            error("Percentage by population divided by 100 needs to be even for BETA caste")
        end
        
        # Validate generated population matches population size
        generated_population = map(x -> round(Int, x * population_size / 100), values(castes_percentages))
        if sum(generated_population) != population_size
            error("Generated population will not match population size")
        end
        
        # Validate positive values
        if chromosome_size <= 0
            error("chromosome_size must be positive")
        end
        if population_size <= 0
            error("population_size must be positive")
        end
        if max_generations <= 0
            error("max_generations must be positive")
        end
        
        # Validate mutation rates are reasonable (between 0 and 100)
        for (caste, rate) in mutation_rate
            if rate < 0 || rate > 100
                error("Mutation rate for $caste must be between 0 and 100, got $rate")
            end
        end
        
        # All validations passed, create the object
        new(chromosome_size, population_size, max_generations, castes_percentages, mutation_rate)
    end
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

    castes_mr =
        Dict{String,Int}(
            alpha => config_parameters[mutation_rate][alpha],
            beta => config_parameters[mutation_rate][beta],
            gamma => config_parameters[mutation_rate][gamma],
            delta => config_parameters[mutation_rate][delta],
            epsilon => config_parameters[mutation_rate][epsilon]
        )

    @info "Configuration parameters read: $(castes_percentages)"

    # The constructor will handle all validation
    return ConfigurationParametersEntity(
        config_parameters[chromosome_size], config_parameters[population_size],
        config_parameters[max_generations], castes_percentages, castes_mr)
end