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


struct Embryo{T<:AbstractArray,N<:Real}
    chromosome::T
    f_value::N
    Embryo(chromosome::T, f_value::N) where {T<: AbstractArray, N<:Real} = new{T,N}(chromosome, f_value)
    function Embryo(chromosome::T, ff::FitnessFunction) where {T<: AbstractArray}
        f_val = ff(chromosome)
        new{T,typeof(f_val)}(chromosome, f_val)
    end
end

struct Individual{T<:AbstractArray, N<:Real, C<:Caste}
    chromosome::T
    f_value::N
    caste::C
end
