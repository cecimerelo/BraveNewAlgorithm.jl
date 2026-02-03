# BraveNewAlgorithm.jl

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A metaheuristic optimization algorithm inspired by Aldous Huxley's "Brave New
World" and its caste system. This algorithm improves the
exploration/exploitation balance of population-based metaheuristics by using
different castes with distinct roles in the evolutionary process.

Among other things, this repository contains data for the experiments performed
for the WALCOM 26 conference; check out the [`data/`](data/) subdirectory. We
used the [`examples/BBOB_sphere.jl`](examples/BBOB_sphere.jl) script, that
optimizes BBOB's `Sphere` function, for these experiments, run from the
[`scripts`](scripts/) directory that includes measurement using the `pinpoint`
tool.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/cecimerelo/BraveNewAlgorithm.jl.git
cd BraveNewAlgorithm.jl

# Install dependencies (this may take a few minutes)
julia examples/setup.jl
# OR use the Makefile: make instantiate

# Run the quick start example
julia examples/quickstart.jl
```

## 📦 Installation

### From GitHub
```julia
using Pkg
Pkg.add(url="https://github.com/cecimerelo/BraveNewAlgorithm.jl.git")
```

### From Julia Registry (if available)
```julia
using Pkg
Pkg.add("BraveNewAlgorithm")
```

### For Development
```bash
git clone https://github.com/cecimerelo/BraveNewAlgorithm.jl.git
cd BraveNewAlgorithm.jl
julia --project=. -e "using Pkg; Pkg.instantiate()"
```

## 🧬 How It Works

The algorithm uses a **caste-based population system** with five distinct castes, each serving a different purpose in the optimization process:

- **ALPHA** (Elite): Best individuals with low mutation rates for exploitation
- **BETA** (High performers): Good solutions with moderate diversity
- **GAMMA** (Average): Balanced exploration and exploitation
- **DELTA** (Below average): Higher mutation for local search
- **EPSILON** (Diverse): Highest mutation rates for exploration and diversity

## 📋 Basic Usage

### Minimal Example

```julia
using Pkg
Pkg.activate(".")  # If using the downloaded repository

include("src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm

# Load required dependencies
using BlackBoxOptimizationBenchmarking
include("src/utils.jl")
include("src/commons.jl")

# 1. Configure the algorithm
config_parameters = ConfigurationParametersEntity(
    5,                    # chromosome_size (problem dimensions)
    30,                   # population_size
    100,                  # max_generations
    Dict{String, Int}(    # caste percentages
        "ALPHA" => 10, "BETA" => 20, "GAMMA" => 30,
        "DELTA" => 25, "EPSILON" => 15
    ),
    Dict{String, Int}(    # mutation rates per caste
        "ALPHA" => 5, "BETA" => 8, "GAMMA" => 12,
        "DELTA" => 15, "EPSILON" => 20
    )
)

# 2. Set up the optimization problem
fitness_function = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1], 0)
search_range = (-5.12, 5.12)
stopping_criterion = (element, ff) -> element >= ff.fitness_function.f_opt + 1e-8

# 3. Create population model
population_model = PopulationModel(
    config_parameters, fitness_function, search_range, stopping_criterion
)

# 4. Run the algorithm
generation, results = brave_new_algorithm(population_model)

# 5. Get results
best_fitness = minimum(results.F_Values)
println("Best fitness found: $best_fitness")
println("Completed in $generation generations")
```

### Using Configuration Files

You can also use JSON configuration files for easier parameter management:

```julia
# Create config.json
config = Dict(
    "CHROMOSOME_SIZE" => 10,
    "POPULATION_SIZE" => 50,
    "MAX_GENERATIONS" => 200,
    "POPULATION_PERCENTAGE" => Dict(
        "ALPHA" => 15, "BETA" => 25, "GAMMA" => 25, "DELTA" => 20, "EPSILON" => 15
    ),
    "MUTATION_RATE" => Dict(
        "ALPHA" => 3, "BETA" => 6, "GAMMA" => 10, "DELTA" => 15, "EPSILON" => 20
    )
)

# Save and load configuration
using JSON
open("config.json", "w") do f; JSON.print(f, config, 4); end
config_parameters = read_parameters_file("config.json")

# Use with algorithm as above...
```

## 🎯 Supported Optimization Problems

Currently, the algorithm works with **BBOB (Black Box Optimization Benchmarking)** functions from the [BlackBoxOptimizationBenchmarking.jl](https://github.com/jonathanfischer97/BlackBoxOptimizationBenchmarking.jl) package:

- **Function 1**: Sphere function (`f(x) = Σx²`)
- **Function 2**: Rosenbrock function  
- **Function 3**: Ellipsoid function
- And more BBOB benchmark functions...

```julia
# Different BBOB functions
sphere_func = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[1], 0)
rosenbrock_func = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[2], 0)
ellipsoid_func = FitnessFunction(BlackBoxOptimizationBenchmarking.BBOBFunctions[3], 0)
```

## ⚙️ Configuration Parameters

| Parameter | Description | Typical Range |
|-----------|-------------|---------------|
| `CHROMOSOME_SIZE` | Problem dimensions | 2-100 |
| `POPULATION_SIZE` | Number of individuals | 20-200 |
| `MAX_GENERATIONS` | Maximum iterations | 50-1000 |
| `POPULATION_PERCENTAGE` | Caste distribution (%) | Must sum to 100 |
| `MUTATION_RATE` | Mutation probability per caste | 1-30 |

### Recommended Caste Distributions

For **exploitation-focused** problems:
```julia
"POPULATION_PERCENTAGE" => Dict(
    "ALPHA" => 25, "BETA" => 30, "GAMMA" => 25, "DELTA" => 15, "EPSILON" => 5
)
```

For **exploration-focused** problems:
```julia
"POPULATION_PERCENTAGE" => Dict(
    "ALPHA" => 10, "BETA" => 15, "GAMMA" => 25, "DELTA" => 25, "EPSILON" => 25
)
```

For **balanced** optimization:
```julia
"POPULATION_PERCENTAGE" => Dict(
    "ALPHA" => 15, "BETA" => 20, "GAMMA" => 30, "DELTA" => 20, "EPSILON" => 15
)
```

## 📊 Output and Results

The algorithm returns:
- **Final generation**: Number of generations completed
- **Results DataFrame** with columns:
  - `Generations`: Generation numbers
  - `F_Values`: Best fitness values per generation
  - `Entropy`: Population diversity measure
  - `Edit_distance`: Population convergence measure

```julia
generation, results = brave_new_algorithm(population_model)

# Access results
best_fitness_evolution = results.F_Values
diversity_evolution = results.Entropy
convergence_measure = results.Edit_distance

# Plot convergence (requires Plots.jl)
using Plots
plot(results.Generations, results.F_Values, 
     xlabel="Generation", ylabel="Best Fitness",
     title="Optimization Progress")
```

## 🔧 Integration in Your Projects

### As a Project Dependency

Add BraveNewAlgorithm to your Julia project dependencies:

```julia
# In Julia REPL or script
using Pkg
Pkg.add(url="https://github.com/cecimerelo/BraveNewAlgorithm.jl.git")
```

Or add to your `Project.toml`:
```toml
[deps]
BraveNewAlgorithm = "62e8e4ba-3e3d-40af-bbe6-192e07c2d347"
```

### As a Library

```julia
# In your Julia project
include("path/to/BraveNewAlgorithm.jl/src/BraveNewAlgorithm.jl")
using .BraveNewAlgorithm

function optimize_my_problem()
    # Your configuration
    config = ConfigurationParametersEntity(...)
    
    # Your fitness function setup
    fitness_func = FitnessFunction(...)
    
    # Create model and run
    model = PopulationModel(config, fitness_func, range, comparator)
    return brave_new_algorithm(model)
end
```

### In Experiments

```julia
# Parameter sweep example
dimensions = [5, 10, 20, 30]
population_sizes = [30, 50, 100]
results = Dict()

for dim in dimensions, pop_size in population_sizes
    config = ConfigurationParametersEntity(dim, pop_size, 200, castes, mutations)
    model = PopulationModel(config, fitness_func, (-5.0, 5.0), comparator)
    
    generation, result_df = brave_new_algorithm(model)
    results[(dim, pop_size)] = (generation, minimum(result_df.F_Values))
end
```

## 📚 Examples

- **[Quick Start](examples/quickstart.jl)**: Minimal working example
- **[Basic Usage](examples/basic_usage_example.jl)**: Comprehensive examples with different configurations
- **[Usage Guide](USAGE.md)**: Complete guide with tips and best practices
- **Test Files**: See `test/` directory for more usage patterns

## 🔬 Research and Citation

If you use this algorithm in your research, please cite:

```bibtex
@Inbook{Merelo2022,
author="Merelo, Cecilia
and Merelo, Juan J.
and Garc{\'i}a-Valdez, Mario",
editor="Castillo, Oscar
and Melin, Patricia",
title="A Brave New Algorithm to Maintain the Exploration/Exploitation Balance",
bookTitle="New Perspectives on Hybrid Intelligent System Design based on Fuzzy Logic, Neural Networks and Metaheuristics",
year="2022",
publisher="Springer International Publishing",
address="Cham",
pages="305--316",
isbn="978-3-031-08266-5",
doi="10.1007/978-3-031-08266-5_20",
url="https://doi.org/10.1007/978-3-031-08266-5_20"
}
```

## 🤝 Contributing

Contributions are welcome! Please see the test files for examples of how the algorithm should behave.

## 📄 License

(c) Cecilia Merelo, 2021, released under the [GNU General Public License v3](LICENSE).
