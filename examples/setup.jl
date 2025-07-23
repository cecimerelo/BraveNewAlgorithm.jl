#!/usr/bin/env julia

"""
Setup script for BraveNewAlgorithm.jl examples

This script installs all required dependencies.
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

function main()
    println("="^60)
    println("BraveNewAlgorithm.jl Setup")
    println("="^60)
    
    # Setup dependencies
    if !setup_dependencies()
        println("\n💥 Setup failed! Please check the error messages above.")
        println("\nYou can also try manually:")
        println("  julia --project=. -e \"using Pkg; Pkg.instantiate()\"")
        println("Or:")
        println("  make instantiate")
        exit(1)
    end
    
    println("\n🎉 Setup completed successfully!")
    println("\nYou can now run the examples:")
    println("  julia examples/quickstart.jl")
    println("  julia examples/basic_usage_example.jl")  
    println("  julia examples/simple_test.jl")
    println("\nTo verify installation:")
    println("  julia examples/simple_test.jl")
    println("\nFor more information, see examples/README.md")
end

# Run setup if this script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end