include("fitness_function.jl")

struct ConfigurationParametersEntity
    chromosome_size::Int
    population_size::Int
    max_generations::Int
    castes_percentages::Dict{String, Int}
    mutation_rate::Dict{String, Int}
end

struct PopulationModel
    config_parameters::ConfigurationParametersEntity
    fitness_function::FitnessFunction
    range::Tuple{Float64,Float64}
    comparator::Function
end

struct Embryo
    chromosome::Vector
    f_value::Real
    Embryo(chromosome::Vector, f_value::Real) = new(chromosome, f_value)
    Embryo(chromosome::Vector, ff::FitnessFunction) = new(chromosome, ff(chromosome))
end

struct Individual
    chromosome::Vector
    f_value::Real
    caste::Caste
end
