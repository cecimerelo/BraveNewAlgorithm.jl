using Pkg
Pkg.activate(".")
include("../src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking
using Base.Threads

include("../src/utils.jl")
include("../src/methods/fertilising_room.jl")
include("./get_offspring.jl")

const POPULATION_SIZE::Int = 400000

function (@main)(args)
    @info "Number of threads -> $(nthreads())"
    config_file_path = "./test/Config Files/config_file_1_test.json"
    config_parameters_entity = read_parameters_file(config_file_path)
    fitness_function = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
    range = (-5.12, 5.12)
    minimum_comparator = comparator(element, fitness_function) = element >= fitness_function.f_opt
    ff = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])
    population_model = PopulationModel(config_parameters_entity, ff, range, minimum_comparator)

    embryos = [fertilising_room(population_model) for _ in 1:POPULATION_SIZE]
    dummy_offspring = get_offspring((embryos[1], embryos[2]))
    @time begin
        chunks = Iterators.partition(embryos, length(embryos) ÷ nthreads())
        tasks = map(chunks) do chunk
            @spawn get_offspring(chunk)
        end
        all_offspring = vcat([fetch(task) for task in tasks]...)
    end

    @info "All offspring -> $(length(all_offspring))"
end
