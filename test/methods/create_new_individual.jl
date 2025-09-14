using .BraveNewAlgorithm

include("../../src/methods/evolution.jl")
include("../../src/individual/embryo.jl")

using Test

@testset "create_new_individual" begin
    config_parameters = ConfigurationParametersEntity(2, 1, 1, Dict{String, Int}(), Dict{String, Int}())
    population_model = PopulationModel(config_parameters, FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1]), (0.0, 1.0), (element, ff) -> element >= ff.f_opt + 1e-6)

    parents = ((1.0, 2.0), (3.0, 4.0))

    offspring1, offspring2 = create_new_individual(parents, population_model.config_parameters, ALPHA())

    @test offspring1[1] != parents[1][1]
    @test offspring1[2] != parents[1][2]
    @test offspring1[1] != parents[2][1]
    @test offspring1[2] != parents[2][2]

    @test offspring2[1] != parents[1][1]
    @test offspring2[2] != parents[1][2]
    @test offspring2[1] != parents[2][1]
    @test offspring2[2] != parents[2][2]

    @test offspring1[1] != offspring2[1]
    @test offspring1[2] != offspring2[2]
end
