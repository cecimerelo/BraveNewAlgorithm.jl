include("../operators/mutation.jl")

const MAX_STEP_SIZE = 0.01
const MAX_LOCAL_SEARCH_ITERATIONS = 64

function local_search(offspring, fitness_function, mutation_rate, range, caste::GAMMA, max_generations = MAX_LOCAL_SEARCH_ITERATIONS, step_fraction = MAX_STEP_SIZE)
    step_size = step_fraction * (last(range) - first(range))
    final_chromosome = copy(offspring)
    original_f_value = Embryo(final_chromosome, fitness_function).f_value

    idx = rand(1:length(final_chromosome))
    original_val = final_chromosome[idx]

    # Probe up direction
    up_val = clamp(original_val + step_size, first(range), last(range))
    final_chromosome[idx] = up_val
    up_f = Embryo(final_chromosome, fitness_function).f_value

    # Probe down direction
    down_val = clamp(original_val - step_size, first(range), last(range))
    final_chromosome[idx] = down_val
    down_f = Embryo(final_chromosome, fitness_function).f_value

    # If neither direction improves, return original chromosome (local optimum)
    if up_f >= original_f_value && down_f >= original_f_value
        return offspring
    end

    # Choose the better direction, reusing already-computed probed values
    if up_f < down_f
        direction = step_size
        f_value = up_f
        final_chromosome[idx] = up_val
    else
        direction = -step_size
        f_value = down_f
    end

    # Walk in the improving direction until no improvement or max iterations reached
    iterations = 0
    while iterations < max_generations
        prev_val = final_chromosome[idx]
        final_chromosome[idx] = clamp(prev_val + direction * rand(), first(range), last(range))
        new_f = Embryo(final_chromosome, fitness_function).f_value
        if new_f < f_value
            f_value = new_f
            iterations += 1
        else
            final_chromosome[idx] = prev_val
            break
        end
    end

    return final_chromosome
end

function local_search(offspring, fitness_function, mutation_rate, range, caste)
    return offspring
end
