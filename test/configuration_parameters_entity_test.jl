# test configuration_parameters_entity.jl including the errors
using .BraveNewAlgorithm
using Test

@testset "ConfigurationParametersEntity Module Test" begin
    @testset "Test read_parameters_file when called then ConfigurationParametersEntity returned" begin
        config_file_path = "./test/Config Files/config_file_1_test.json"
        config_entity = read_parameters_file(config_file_path)

        @test typeof(config_entity) == ConfigurationParametersEntity
        @test typeof(config_entity.castes_percentages) == Dict{String, Int64}
    end
end

# config_file_2_test.json will raise an error
@testset "Test read_parameters_file when called then error raised" begin
    config_file_path = "./test/Config Files/config_file_2_test.json"
    @test_throws ErrorException read_parameters_file(config_file_path)
end
