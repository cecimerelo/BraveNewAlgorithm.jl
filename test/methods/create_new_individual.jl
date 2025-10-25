using .BraveNewAlgorithm

using Test

@testset "create_new_individual" begin
    # Use higher mutation rate (50%) to ensure mutation happens with small chromosome size
    test_mutation_rate = 50

    parents = (
        Individual([1.0, 2.0], 0.5, ALPHA()),
        Individual([3.0, 4.0], 0.8, ALPHA())
    )

    offspring1, offspring2 = create_new_individual(parents, test_mutation_rate, (-5.12, 5.12))

    # Test that function returns two offspring arrays
    @test typeof(offspring1) == Array{Float64,1}
    @test typeof(offspring2) == Array{Float64,1}
    @test length(offspring1) == 2
    @test length(offspring2) == 2

    # Test that offspring are different from each other
    @test offspring1 != offspring2

    # Test that offspring are different from original parents (crossover + mutation should change them)
    @test offspring1 != parents[1].chromosome || offspring1 != parents[2].chromosome
    @test offspring2 != parents[1].chromosome || offspring2 != parents[2].chromosome
end
