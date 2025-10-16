using Distributions
using Random  # For randperm to ensure unique mutation indices

"""
    mutation_operator(offspring, mutation_percentage)

Apply mutation to `offspring` based on `mutation_percentage`. The value of this should be between 0 and 100 (strict)
"""
function mutation_operator(offspring, mutation_percentage)
    (mutation_percentage < 100 && mutation_percentage > 0)|| throw(ArgumentError("Mutation percentage must be less than 100"))
    mutated_offspring = copy(offspring)
    genes_to_mutate = floor(Int, mutation_percentage * length(offspring) / 100)
    
    # Use randperm to avoid overlapping indices
    if genes_to_mutate > 0
        indexes_to_mutate = randperm(length(offspring))[1:genes_to_mutate]
        
        # Directly modify the mutated indices
        for mutation_index in indexes_to_mutate
            mutated_offspring[mutation_index] = rand()
        end
    end

    return mutated_offspring
end

"""
    gaussian_mutation_operator(offspring, mutation_percentage, range, sigma_percentage=10.0)

Apply Gaussian mutation to `offspring` based on `mutation_percentage`. 
Instead of replacing genes with random values, this operator adds Gaussian noise to existing values.

# Arguments
- `offspring`: The chromosome to mutate
- `mutation_percentage`: Percentage of genes to mutate (0-100)
- `range`: Tuple (min, max) defining the valid range for gene values
- `sigma_percentage`: Standard deviation as a percentage of the range width (default: 10.0)
  The default of 10% provides a good balance between exploration and exploitation,
  making small enough perturbations to improve solutions locally without disrupting them too much.

# Returns
- Mutated offspring with Gaussian noise added to selected genes
"""
function gaussian_mutation_operator(offspring, mutation_percentage, range, sigma_percentage=10.0)
    (mutation_percentage < 100 && mutation_percentage > 0) || throw(ArgumentError("Mutation percentage must be between 0 and 100"))
    (sigma_percentage > 0 && sigma_percentage <= 100) || throw(ArgumentError("Sigma percentage must be between 0 and 100"))
    
    mutated_offspring = copy(offspring)
    genes_to_mutate = floor(Int, mutation_percentage * length(offspring) / 100)
    
    # Calculate standard deviation based on range width
    range_width = range[2] - range[1]
    sigma = (sigma_percentage / 100.0) * range_width
    
    # Use randperm to avoid overlapping indices
    if genes_to_mutate > 0
        indexes_to_mutate = randperm(length(offspring))[1:genes_to_mutate]
        
        # Directly modify the mutated indices
        for mutation_index in indexes_to_mutate
            # Add Gaussian noise to the existing gene value
            noise = rand(Normal(0.0, sigma))
            new_gene = offspring[mutation_index] + noise
            
            # Clamp to valid range
            mutated_offspring[mutation_index] = clamp(new_gene, range[1], range[2])
        end
    end

    return mutated_offspring
end