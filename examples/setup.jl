#!/usr/bin/env julia

"""
Setup script for BraveNewAlgorithm.jl examples

This script installs all required dependencies and verifies the installation.
Run this before using any examples.
"""

using Pkg

function setup_dependencies()
    println("🔧 Setting up BraveNewAlgorithm.jl dependencies...")
    
    # Activate the project environment
    println("Activating project environment...")
    Pkg.activate(".")
    
    # Install dependencies
    println("Installing dependencies (this may take a few minutes)...")
    try
        Pkg.instantiate()
        println("✅ Dependencies installed successfully!")
        return true
    catch e
        println("❌ Failed to install dependencies:")
        println(e)
        return false
    end
end

function verify_installation()
    println("\n🧪 Verifying installation...")
    
    try
        # Test core imports
        println("Testing core module import...")
        include("../src/BraveNewAlgorithm.jl")
        using .BraveNewAlgorithm
        println("✅ BraveNewAlgorithm module loads correctly")
        
        # Test BBOB functions
        println("Testing BBOB functions...")
        using BlackBoxOptimizationBenchmarking
        test_func = BlackBoxOptimizationBenchmarking.BBOBFunctions[1]
        println("✅ BBOB functions available")
        
        # Test utility functions
        println("Testing utility functions...")
        include("../src/utils.jl")
        include("../src/commons.jl")
        println("✅ Utility functions load correctly")
        
        # Test basic types
        println("Testing basic configuration...")
        config = ConfigurationParametersEntity(
            5, 10, 5,
            Dict("ALPHA" => 20, "BETA" => 20, "GAMMA" => 20, "DELTA" => 20, "EPSILON" => 20),
            Dict("ALPHA" => 10, "BETA" => 10, "GAMMA" => 10, "DELTA" => 10, "EPSILON" => 10)
        )
        fitness_func = FitnessFunction(test_func, 0)
        println("✅ Configuration objects created successfully")
        
        return true
        
    catch e
        println("❌ Verification failed:")
        println(e)
        return false
    end
end

function main()
    println("="^60)
    println("BraveNewAlgorithm.jl Setup")
    println("="^60)
    
    # Setup dependencies
    if !setup_dependencies()
        println("\n💥 Setup failed! Please check the error messages above.")
        exit(1)
    end
    
    # Verify installation
    if !verify_installation()
        println("\n💥 Verification failed! The installation may be incomplete.")
        exit(1)
    end
    
    println("\n🎉 Setup completed successfully!")
    println("\nYou can now run the examples:")
    println("  julia examples/quickstart.jl")
    println("  julia examples/basic_usage_example.jl")
    println("  julia examples/simple_test.jl")
    println("\nFor more information, see examples/README.md")
end

# Run setup if this script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end