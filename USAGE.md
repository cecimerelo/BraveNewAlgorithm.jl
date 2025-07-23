# Usage Guide: BraveNewAlgorithm.jl

## What is BraveNewAlgorithm.jl?

BraveNewAlgorithm.jl is a metaheuristic optimization algorithm inspired by Aldous Huxley's "Brave New World". It uses a **caste-based population system** to maintain an optimal balance between exploration and exploitation during optimization.

## Key Concepts

### 🏛️ The Caste System

The algorithm divides the population into five castes, each with a specific role:

| Caste | Role | Mutation Rate | Purpose |
|-------|------|---------------|---------|
| **ALPHA** | Elite | Low (3-10%) | Preserve best solutions, exploitation |
| **BETA** | High performers | Moderate (6-12%) | Local improvement |
| **GAMMA** | Average | Standard (10-15%) | Balanced search |
| **DELTA** | Below average | Higher (12-18%) | Diversified search |
| **EPSILON** | Explorers | Highest (15-25%) | Exploration, diversity |

### 🎯 How It Works

1. **Initialization**: Create a population with random individuals
2. **Caste Assignment**: Assign individuals to castes based on fitness
3. **Evolution**: Apply caste-specific operators (mutation, crossover)
4. **Selection**: Select survivors for the next generation
5. **Repeat**: Continue until stopping criterion is met

## Quick Start

### 1. Installation

```bash
git clone https://github.com/cecimerelo/BraveNewAlgorithm.jl.git
cd BraveNewAlgorithm.jl
julia examples/setup.jl
```

### 2. Basic Usage

```julia
# Load the algorithm
include("src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm
using BlackBoxOptimizationBenchmarking
include("src/utils.jl")
include("src/commons.jl")

# Configure the algorithm
config = ConfigurationParametersEntity(
    5,    # dimensions
    30,   # population size  
    100,  # max generations
    Dict("ALPHA" => 15, "BETA" => 20, "GAMMA" => 30, "DELTA" => 20, "EPSILON" => 15),
    Dict("ALPHA" => 5, "BETA" => 8, "GAMMA" => 12, "DELTA" => 15, "EPSILON" => 20)
)

# Set up the problem
fitness_func = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1], 0)
model = PopulationModel(config, fitness_func, (-5.0, 5.0), stopping_criterion)

# Run optimization
generation, results = brave_new_algorithm(model)
best_fitness = minimum(results.F_Values)
```

### 3. Available Examples

| File | Description | Runtime |
|------|-------------|---------|
| `examples/quickstart.jl` | Minimal working example | ~30 seconds |
| `examples/basic_usage_example.jl` | Comprehensive tutorial | ~2-5 minutes |
| `examples/simple_test.jl` | Quick verification | ~10 seconds |

## Configuration Guide

### Population Sizing

- **Small problems** (dimensions < 10): Population 20-50
- **Medium problems** (dimensions 10-30): Population 50-100  
- **Large problems** (dimensions > 30): Population 100-200

### Caste Distribution Strategies

**For exploitation-heavy problems** (fine-tuning):
```julia
"POPULATION_PERCENTAGE" => Dict(
    "ALPHA" => 25, "BETA" => 30, "GAMMA" => 25, "DELTA" => 15, "EPSILON" => 5
)
```

**For exploration-heavy problems** (multimodal):
```julia
"POPULATION_PERCENTAGE" => Dict(
    "ALPHA" => 10, "BETA" => 15, "GAMMA" => 25, "DELTA" => 25, "EPSILON" => 25
)
```

**Balanced approach** (general use):
```julia
"POPULATION_PERCENTAGE" => Dict(
    "ALPHA" => 15, "BETA" => 20, "GAMMA" => 30, "DELTA" => 20, "EPSILON" => 15
)
```

### Mutation Rate Guidelines

- **ALPHA**: 3-8% (preserve elite solutions)
- **BETA**: 6-12% (local improvement)
- **GAMMA**: 10-15% (standard search)
- **DELTA**: 12-18% (increased diversity)
- **EPSILON**: 15-25% (maximum exploration)

## Supported Problems

Currently supports **BBOB (Black Box Optimization Benchmarking)** functions:

```julia
# Common BBOB functions
sphere_func = BBOBFunctions[1]      # f(x) = Σx²
rosenbrock_func = BBOBFunctions[2]  # Rosenbrock function
ellipsoid_func = BBOBFunctions[3]   # Ellipsoid function
# ... up to BBOBFunctions[24]
```

## Results Analysis

The algorithm returns detailed results:

```julia
generation, results = brave_new_algorithm(model)

# Access optimization data
best_fitness_per_generation = results.F_Values
population_diversity = results.Entropy  
convergence_measure = results.Edit_distance
generation_numbers = results.Generations

# Quick analysis
final_best = minimum(results.F_Values)
convergence_rate = (results.F_Values[1] - final_best) / length(results.F_Values)
```

## Integration Patterns

### In Research Scripts

```julia
function run_experiment(config_file, problem_id)
    config = read_parameters_file(config_file)
    fitness_func = FitnessFunction(BBOBFunctions[problem_id], 0)
    model = PopulationModel(config, fitness_func, (-5.0, 5.0), stopping_criterion)
    
    start_time = time()
    generation, results = brave_new_algorithm(model)
    elapsed_time = time() - start_time
    
    return Dict(
        "best_fitness" => minimum(results.F_Values),
        "generations" => generation,
        "time" => elapsed_time,
        "evaluations" => fitness_func.calls_counter
    )
end
```

### Parameter Sweeps

```julia
function parameter_sweep()
    results = Dict()
    
    for pop_size in [30, 50, 100]
        for alpha_pct in [10, 15, 20, 25]
            config = create_config(pop_size, alpha_pct)
            result = run_optimization(config)
            results[(pop_size, alpha_pct)] = result
        end
    end
    
    return results
end
```

## Tips for Best Results

1. **Start simple**: Use the quickstart configuration and adapt
2. **Monitor diversity**: High entropy = good exploration
3. **Watch convergence**: Edit distance shows population convergence  
4. **Tune gradually**: Change one parameter at a time
5. **Multiple runs**: Average results over several runs for reliability

## Troubleshooting

**Dependencies not installed?**
```bash
julia examples/setup.jl
# OR
make instantiate
```

**Examples not working?**
- Ensure you're in the repository root directory
- Check that setup completed successfully

**Performance issues?**
- Reduce population size or dimensions for testing
- Monitor function evaluation count
- Consider the problem's computational complexity

## Further Reading

- **Paper**: [Original research paper](https://doi.org/10.1007/978-3-031-08266-5_20)
- **Examples**: See `examples/` directory for working code
- **Tests**: Check `test/` directory for algorithm validation
- **Source**: Explore `src/` for implementation details