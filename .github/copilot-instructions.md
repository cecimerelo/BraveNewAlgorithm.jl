# GitHub Copilot Instructions for BraveNewAlgorithm.jl

## Repository Overview

BraveNewAlgorithm.jl is a Julia metaheuristic optimization algorithm inspired by Aldous Huxley's "Brave New World". It uses a caste-based population system with five distinct castes (ALPHA, BETA, GAMMA, DELTA, EPSILON) to maintain exploration/exploitation balance.

## Project Structure

```
BraveNewAlgorithm.jl/
├── src/                          # Core algorithm implementation
│   ├── BraveNewAlgorithm.jl     # Main module file
│   ├── brave_new_algorithm.jl   # Main algorithm implementation
│   ├── commons.jl               # Common data structures
│   ├── utils.jl                 # Utility functions
│   ├── individual/              # Individual and fitness structures
│   ├── methods/                 # Algorithm methods (hatchery, evolution, etc.)
│   └── operators/               # Genetic operators (crossover, mutation, selection)
├── examples/                     # Usage examples and demos
│   ├── setup.jl                # Dependency setup script
│   ├── quickstart.jl           # Quick start example
│   ├── simple_test.jl          # Basic functionality test
│   └── basic_usage_example.jl  # Comprehensive examples
├── test/                        # Test suite
│   ├── runtests.jl             # Main test runner
│   ├── methods/                # Method tests
│   ├── operators/              # Operator tests
│   └── Config Files/           # Test configuration files
├── data/                        # Data files and results
├── Project.toml                 # Julia package dependencies
├── Manifest.toml               # Locked dependency versions
├── Makefile                    # Build automation
├── README.md                   # Main documentation
└── USAGE.md                    # Detailed usage guide
```

## Development Environment Setup

### Prerequisites
- Julia 1.4+ (tested with Julia 1.10.10)
- Git for version control

### Quick Setup
```bash
# Clone repository
git clone https://github.com/cecimerelo/BraveNewAlgorithm.jl.git
cd BraveNewAlgorithm.jl

# Install dependencies (choose one method)
julia examples/setup.jl              # Recommended: user-friendly setup
make instantiate                     # Alternative: Makefile
julia --project=. -e "using Pkg; Pkg.instantiate()"  # Manual
```

### Build Process
- **Dependency Installation**: ~3-5 minutes (varies by network)
- **Package Precompilation**: ~2-4 minutes
- **Test Suite**: ~30-60 seconds

### Validation Commands
```bash
# Test installation
make tests                           # Run full test suite (~30-60 seconds)
julia examples/simple_test.jl       # Basic functionality test (~10 seconds)
julia test/runtests.jl              # Manual test execution

# Check functionality
julia examples/quickstart.jl        # Quick example (~10-30 seconds)
```

## Core Dependencies

### Essential Packages
- **BlackBoxOptimizationBenchmarking.jl**: BBOB benchmark functions
- **JSON.jl**: Configuration file parsing
- **DataFrames.jl**: Results storage and manipulation
- **BenchmarkTools.jl**: Performance measurement
- **CSV.jl**: Data export capabilities

### Optional Visualization
- **Plots.jl**: Convergence plotting
- **StatsPlots.jl**: Statistical visualizations
- **Gadfly.jl**: Alternative plotting backend

## Key API Components

### Configuration Structure
```julia
ConfigurationParametersEntity(
    chromosome_size::Int,           # Problem dimensions (2-100)
    population_size::Int,           # Population size (20-200)
    max_generations::Int,           # Maximum generations (50-1000)
    castes_percentages::Dict{String, Int},  # Caste distribution (must sum to 100)
    mutation_rates::Dict{String, Int}       # Mutation rates per caste (1-30)
)
```

### Fitness Function Setup
```julia
# Using BBOB functions
fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])

# Available BBOB functions:
# [1] Sphere function
# [2] Rosenbrock function  
# [3] Ellipsoid function
# ... (see BlackBoxOptimizationBenchmarking.jl docs)
```

### Population Model
```julia
PopulationModel(
    config_parameters::ConfigurationParametersEntity,
    fitness_function::FitnessFunction,
    search_range::Tuple{Float64, Float64},     # e.g., (-5.0, 5.0)
    stopping_criterion::Function               # e.g., (element, ff) -> element >= ff.fitness_function.f_opt + 1e-8
)
```

### Algorithm Execution
```julia
generation, results = brave_new_algorithm(population_model)
# Returns: final generation number, DataFrame with results
```

## Working Code Templates

### Minimal Working Example
```julia
using Pkg
Pkg.activate(".")

include("src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking
include("src/utils.jl")
include("src/commons.jl")

# Configuration
config = ConfigurationParametersEntity(
    5,                              # 5 dimensions
    30,                             # 30 individuals
    100,                            # 100 generations max
    Dict("ALPHA" => 10, "BETA" => 20, "GAMMA" => 30, "DELTA" => 25, "EPSILON" => 15),
    Dict("ALPHA" => 5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 20)
)

# Fitness function (Sphere function)
fitness_func = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1])

# Model and execution
model = PopulationModel(config, fitness_func, (-5.0, 5.0), 
                       (element, ff) -> element >= ff.fitness_function.f_opt + 1e-8)
generation, results = brave_new_algorithm(model)

println("Best fitness: $(minimum(results.F_Values))")
```

### Configuration File Usage
```julia
# Create config.json
config_dict = Dict(
    "CHROMOSOME_SIZE" => 10,
    "POPULATION_SIZE" => 50,
    "MAX_GENERATIONS" => 200,
    "POPULATION_PERCENTAGE" => Dict("ALPHA" => 15, "BETA" => 25, "GAMMA" => 25, "DELTA" => 20, "EPSILON" => 15),
    "MUTATION_RATE" => Dict("ALPHA" => 3, "BETA" => 6, "GAMMA" => 10, "DELTA" => 15, "EPSILON" => 20)
)

using JSON
open("config.json", "w") do f
    JSON.print(f, config_dict, 4)
end

# Load configuration
config_parameters = read_parameters_file("config.json")
```

## Caste System Guidelines

### Recommended Distributions

**Exploitation-focused** (for fine-tuning):
```julia
"POPULATION_PERCENTAGE" => Dict("ALPHA" => 25, "BETA" => 30, "GAMMA" => 25, "DELTA" => 15, "EPSILON" => 5)
```

**Exploration-focused** (for diverse search):
```julia
"POPULATION_PERCENTAGE" => Dict("ALPHA" => 10, "BETA" => 15, "GAMMA" => 25, "DELTA" => 25, "EPSILON" => 25)
```

**Balanced** (general purpose):
```julia
"POPULATION_PERCENTAGE" => Dict("ALPHA" => 15, "BETA" => 20, "GAMMA" => 30, "DELTA" => 20, "EPSILON" => 15)
```

### Mutation Rate Guidelines
- **ALPHA**: 3-10% (low mutation for elite preservation)
- **BETA**: 6-12% (moderate mutation for local improvement)
- **GAMMA**: 10-15% (standard mutation for balanced search)
- **DELTA**: 12-18% (higher mutation for diversification)
- **EPSILON**: 15-25% (highest mutation for exploration)

## Testing Strategy

### Test Structure
- **Unit Tests**: Individual components (operators, methods)
- **Integration Tests**: Algorithm workflow
- **Performance Tests**: Benchmark function optimization

### Running Tests
```bash
# Full test suite
make tests

# Specific test categories
julia --project=. test/methods/hatchery_test.jl      # Method tests
julia --project=. test/operators/crossover_test.jl   # Operator tests
julia --project=. test/commons_test.jl               # Common structures
```

### Test Data
- Configuration files in `test/Config Files/`
- Small problem sizes for fast execution
- Multiple BBOB function tests

## Common Issues and Solutions

### Dependency Issues
```bash
# If precompilation fails
julia --project=. -e "using Pkg; Pkg.build()"

# If BlackBoxOptimizationBenchmarking issues
julia --project=. -e "using Pkg; Pkg.update()"

# Clear package cache if needed
rm -rf ~/.julia/compiled
```

### Memory Considerations
- Large populations (>200) may require significant memory
- Long runs (>1000 generations) can accumulate results
- Consider result streaming for very long optimizations

### Performance Tips
- Start with small populations for testing
- Use appropriate stopping criteria
- Monitor convergence with results DataFrame

## Results Analysis

### Output Structure
```julia
results::DataFrame
├── Generations::Vector{Int}     # Generation numbers
├── F_Values::Vector{Float64}    # Best fitness per generation
├── Entropy::Vector{Float64}     # Population diversity measure
└── Edit_distance::Vector{Float64}  # Population convergence measure
```

### Analysis Examples
```julia
# Convergence analysis
using Plots
plot(results.Generations, results.F_Values, xlabel="Generation", ylabel="Best Fitness")

# Diversity tracking
plot(results.Generations, results.Entropy, xlabel="Generation", ylabel="Entropy")

# Performance metrics
best_fitness = minimum(results.F_Values)
final_generation = maximum(results.Generations)
function_evaluations = fitness_function.calls_counter
```

## Development Guidelines

### Code Style
- Follow Julia naming conventions
- Use descriptive variable names
- Include docstrings for public functions
- Add unit tests for new features

### File Organization
- New methods go in `src/methods/`
- New operators go in `src/operators/`
- Tests mirror source structure
- Examples should be self-contained

### Performance Considerations
- Profile algorithm bottlenecks
- Consider type stability
- Use appropriate data structures
- Monitor memory allocation

## Troubleshooting Guide

### Common Error Patterns
1. **"Method definition overwritten"**: Check for duplicate includes
2. **"type BBOBFunction has no field fitness_function"**: Use correct API: `ff.fitness_function.f_opt`
3. **"type Tuple has no field chromosome"**: Check data structure usage
4. **"Precompilation failed"**: Try `Pkg.build()` and restart Julia

### Debug Steps
1. Verify dependencies with `make tests`
2. Check simple examples first
3. Use Julia's built-in profiling tools
4. Check algorithm convergence plots

### Getting Help
- Check `examples/` for working code patterns
- Run `julia examples/simple_test.jl` for basic validation
- Consult `USAGE.md` for detailed usage patterns
- Review test files for API examples

## Performance Expectations

### Typical Runtimes
- **Setup**: 3-5 minutes (first time)
- **Simple test**: 10-30 seconds
- **Medium problem** (30 pop, 100 gen): 1-5 minutes
- **Large problem** (100 pop, 500 gen): 10-30 minutes

### Scalability Guidelines
- **Problem dimensions**: Tested up to 100D
- **Population size**: 20-200 individuals
- **Generations**: 50-1000 typical range
- **Memory usage**: ~10MB per 100 individuals per 1000 generations

## Integration Patterns

### As Library Dependency
```julia
# Add to Project.toml
[deps]
BraveNewAlgorithm = "62e8e4ba-3e3d-40af-bbe6-192e07c2d347"
```

### In Research Scripts
```julia
# Parameter sweep example
results_dict = Dict()
for pop_size in [30, 50, 100]
    config = ConfigurationParametersEntity(dims, pop_size, 200, castes, mutations)
    model = PopulationModel(config, fitness_func, range, comparator)
    gen, res = brave_new_algorithm(model)
    results_dict[pop_size] = (gen, minimum(res.F_Values))
end
```

### In Optimization Pipelines
```julia
function optimize_problem(problem_config)
    # Setup from config
    config = read_parameters_file(problem_config["config_file"])
    fitness_func = FitnessFunction(problem_config["bbob_function"])
    
    # Run optimization
    model = PopulationModel(config, fitness_func, problem_config["range"], problem_config["comparator"])
    return brave_new_algorithm(model)
end
```

This comprehensive guide should help developers understand the repository structure, setup process, key APIs, common patterns, and troubleshooting approaches for BraveNewAlgorithm.jl.