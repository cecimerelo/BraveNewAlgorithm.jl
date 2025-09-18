# Test validation in ConfigurationParametersEntity constructor
using .BraveNewAlgorithm
using Test

@testset "ConfigurationParametersEntity Validation Tests" begin
    @testset "Valid configurations should be accepted" begin
        # Test 1: Basic valid configuration
        config = ConfigurationParametersEntity(
            5,
            20,
            50,
            Dict{String, Int}(
                "ALPHA" => 10,
                "BETA" => 20,
                "GAMMA" => 30,
                "DELTA" => 25,
                "EPSILON" => 15
            ),
            Dict{String, Int}(
                "ALPHA" => 5,
                "BETA" => 8,
                "GAMMA" => 12,
                "DELTA" => 15,
                "EPSILON" => 20
            )
        )
        @test typeof(config) == ConfigurationParametersEntity
        @test config.chromosome_size == 5
        @test config.population_size == 20
        @test config.max_generations == 50
    end

    @testset "Invalid percentage sum should be rejected" begin
        @test_throws ErrorException ConfigurationParametersEntity(
            5, 20, 50,
            Dict{String, Int}(
                "ALPHA" => 10,
                "BETA" => 20,
                "GAMMA" => 30,
                "DELTA" => 25,
                "EPSILON" => 20  # Total = 105
            ),
            Dict{String, Int}(
                "ALPHA" => 5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 20
            )
        )
    end

    @testset "Alpha >= Beta should be rejected" begin
        @test_throws ErrorException ConfigurationParametersEntity(
            5, 20, 50,
            Dict{String, Int}(
                "ALPHA" => 25,  # Alpha >= Beta
                "BETA" => 20,
                "GAMMA" => 30,
                "DELTA" => 15,
                "EPSILON" => 10
            ),
            Dict{String, Int}(
                "ALPHA" => 5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 20
            )
        )
    end

    @testset "Missing castes should be rejected" begin
        @test_throws ErrorException ConfigurationParametersEntity(
            5, 20, 50,
            Dict{String, Int}(
                "ALPHA" => 10,
                "BETA" => 20,
                "GAMMA" => 30,
                "DELTA" => 40
                # Missing EPSILON
            ),
            Dict{String, Int}(
                "ALPHA" => 5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 20
            )
        )
    end

    @testset "Negative values should be rejected" begin
        @test_throws ErrorException ConfigurationParametersEntity(
            -5,  # Negative chromosome_size
            20, 50,
            Dict{String, Int}(
                "ALPHA" => 10, "BETA" => 20, "GAMMA" => 30, "DELTA" => 25, "EPSILON" => 15
            ),
            Dict{String, Int}(
                "ALPHA" => 5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 20
            )
        )

        @test_throws ErrorException ConfigurationParametersEntity(
            5, -20, 50,  # Negative population_size
            Dict{String, Int}(
                "ALPHA" => 10, "BETA" => 20, "GAMMA" => 30, "DELTA" => 25, "EPSILON" => 15
            ),
            Dict{String, Int}(
                "ALPHA" => 5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 20
            )
        )

        @test_throws ErrorException ConfigurationParametersEntity(
            5, 20, -50,  # Negative max_generations
            Dict{String, Int}(
                "ALPHA" => 10, "BETA" => 20, "GAMMA" => 30, "DELTA" => 25, "EPSILON" => 15
            ),
            Dict{String, Int}(
                "ALPHA" => 5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 20
            )
        )
    end

    @testset "Invalid mutation rates should be rejected" begin
        @test_throws ErrorException ConfigurationParametersEntity(
            5, 20, 50,
            Dict{String, Int}(
                "ALPHA" => 10, "BETA" => 20, "GAMMA" => 30, "DELTA" => 25, "EPSILON" => 15
            ),
            Dict{String, Int}(
                "ALPHA" => 5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 150  # >100
            )
        )

        @test_throws ErrorException ConfigurationParametersEntity(
            5, 20, 50,
            Dict{String, Int}(
                "ALPHA" => 10, "BETA" => 20, "GAMMA" => 30, "DELTA" => 25, "EPSILON" => 15
            ),
            Dict{String, Int}(
                "ALPHA" => -5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 20  # <0
            )
        )
    end

    @testset "Even division validation for ALPHA and BETA" begin
        # Should fail: ALPHA gives odd number (10% of 10 = 1)
        @test_throws ErrorException ConfigurationParametersEntity(
            5, 10, 50,
            Dict{String, Int}(
                "ALPHA" => 10,  # 10% of 10 = 1 (odd)
                "BETA" => 20,   # 20% of 10 = 2 (even)
                "GAMMA" => 30,
                "DELTA" => 25,
                "EPSILON" => 15
            ),
            Dict{String, Int}(
                "ALPHA" => 5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 20
            )
        )

        # Should fail: BETA gives odd number (30% of 10 = 3)
        @test_throws ErrorException ConfigurationParametersEntity(
            5, 10, 50,
            Dict{String, Int}(
                "ALPHA" => 20,  # 20% of 10 = 2 (even)
                "BETA" => 30,   # 30% of 10 = 3 (odd)
                "GAMMA" => 20,
                "DELTA" => 20,
                "EPSILON" => 10
            ),
            Dict{String, Int}(
                "ALPHA" => 5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 20
            )
        )
    end
end