include("fitness_function.jl")
include("../configuration_parameters_entity.jl")

struct PopulationModel
    config_parameters::ConfigurationParametersEntity
    fitness_function::FitnessFunction
    range::Tuple{Float64,Float64}
    comparator::Function
end

function build_population_model(config_file, fitness_function)
    range = (-5, 5)
    config_file_path = "./data/Config Files/$(config_file).json"
    config_parameters_entity = read_parameters_file(config_file_path)
    minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt
    @info "Config file -> $(config_file_path), Fitness Funcion -> $(fitness_function), Range -> $(range), f_opt -> $(fitness_function.fitness_function.f_opt)"
    return PopulationModel(config_parameters_entity, fitness_function, range, minimum_comparator)
end

struct Embryo{T<:AbstractArray,N<:Real}
    chromosome::T
    f_value::N
    Embryo(chromosome::T, f_value::N) where {T<: AbstractArray, N<:Real} = new{T,N}(chromosome, f_value)
    function Embryo(chromosome::T, ff::FitnessFunction) where {T<: AbstractArray}
        f_val::Float64 = ff(chromosome)
        new{T,Float64}(chromosome, f_val)
    end
end

struct Individual{T<:AbstractArray, N<:Real, C<:Caste}
    chromosome::T
    f_value::N
    caste::C
end
