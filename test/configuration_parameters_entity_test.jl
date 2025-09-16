# test configuration_parameters_entity.jl including the errors
using .BraveNewAlgorithm
using Test

@testset "ConfigurationParametersEntity Module Test" begin
    # Test valid configuration files
    for config_file in ["config_file_1_test.json", "config_file_3_test.json"]
        config_file_path = "./test/Config Files/$(config_file)"
        config_entity = read_parameters_file(config_file_path)
        @testset "Test read_parameters_file with $(config_file)" begin
            @test typeof(config_entity) == ConfigurationParametersEntity
            @test typeof(config_entity.castes_percentages) == Dict{String, Int64}
        end
        @testset "The percentages of $(config_file) add up to 100" begin
            percentages = config_entity.castes_percentages
            @test sum(values(percentages)) == 100
        end
    end
end

# config_file_2_test.json will raise an error
@testset "Test read_parameters_file when called then error raised" begin
    config_file_path = "./test/Config Files/config_file_2_test.json"
    @test_throws ErrorException read_parameters_file(config_file_path)
end
