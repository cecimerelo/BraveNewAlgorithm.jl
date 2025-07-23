# BraveNewAlgorithm.jl Examples

This directory contains practical examples demonstrating how to use the BraveNewAlgorithm.jl package.

## 📁 Example Files

### 🚀 [quickstart.jl](quickstart.jl)
**Start here!** A minimal example that gets you up and running quickly.
- Simple configuration
- Single optimization run
- Clear output with progress information
- **Runtime**: ~10-30 seconds

```bash
julia examples/quickstart.jl
```

### 📚 [basic_usage_example.jl](basic_usage_example.jl) 
Comprehensive examples showing different ways to use the algorithm:
- **Example 1**: Using JSON configuration files
- **Example 2**: Programmatic configuration setup
- **Example 3**: Working with different BBOB functions
- Detailed explanations and comments

```bash
julia examples/basic_usage_example.jl
```

### 🧪 [simple_test.jl](simple_test.jl)
A minimal test to verify the algorithm works correctly:
- Quick verification that the algorithm runs
- Minimal configuration for fast execution
- Basic assertions to check functionality
- **Runtime**: ~5-15 seconds

```bash
julia examples/simple_test.jl
```

## 🛠️ Running the Examples

### First Time Setup

Before running any examples, you need to install the dependencies:

```bash
# From the repository root
cd BraveNewAlgorithm.jl

# Run the setup script (this may take a few minutes)
julia examples/setup.jl
```

Alternatively, you can use the Makefile:
```bash
make instantiate
```

### Running Examples

Once dependencies are installed:

```bash
# Quick demo (recommended first run)
julia examples/quickstart.jl

# Comprehensive examples
julia examples/basic_usage_example.jl

# Simple verification test
julia examples/simple_test.jl
```

**Note**: All examples should be run from the repository root directory with the project environment activated.

## 📋 What You'll Learn

After running these examples, you'll understand:

1. **Basic Setup**: How to configure the algorithm parameters
2. **Population Model**: Creating and customizing the optimization setup
3. **Caste System**: Understanding the five castes and their roles
4. **Results Interpretation**: How to read and use the optimization results
5. **Integration**: How to incorporate the algorithm into your own projects

## ⚙️ Example Parameters

The examples use different parameter settings to demonstrate various use cases:

| Example | Dimensions | Population | Generations | Focus |
|---------|------------|------------|-------------|-------|
| quickstart | 5 | 20 | 50 | Quick demo |
| basic_usage | 5-8 | 25-40 | 30-100 | Comprehensive |
| simple_test | 3 | 10 | 5 | Fast verification |

## 🎯 Next Steps

After running these examples:

1. **Modify parameters** to see how they affect performance
2. **Try different BBOB functions** (Functions 1-24 available)
3. **Experiment with caste distributions** for your specific problem
4. **Integrate the algorithm** into your own optimization projects

## 💡 Tips for Your Own Problems

- Start with the quickstart configuration and adjust as needed
- For high-dimensional problems (>20), increase population size
- For exploration-heavy problems, increase EPSILON percentage
- For fine-tuning, increase ALPHA percentage
- Monitor the entropy and edit_distance metrics for diversity insights

## 🔍 Troubleshooting

**Dependencies missing?**
```bash
julia --project=. -e "using Pkg; Pkg.instantiate()"
```

**Examples not working?**
Make sure you're running from the repository root and have activated the project environment.

**Need help?** Check the main [README.md](../README.md) for more detailed documentation.