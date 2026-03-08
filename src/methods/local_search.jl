include("../operators/mutation.jl")

const MAX_LOCAL_SEARCH_ITERATIONS = 10
function local_search(offspring, fitness_function, mutation_rate, range, caste::GAMMA, max_generations = MAX_LOCAL_SEARCH_ITERATIONS)
    step_size = 0.01 * (last(range) - first(range))
    final_chromosome = copy(offspring)
    f_value = Embryo(final_chromosome, fitness_function).f_value

    for idx in 1:length(final_chromosome)
        up_chromosome = copy(final_chromosome)
        up_chromosome[idx] = clamp(final_chromosome[idx] + step_size, first(range), last(range))
        up_f = Embryo(up_chromosome, fitness_function).f_value

        down_chromosome = copy(final_chromosome)
        down_chromosome[idx] = clamp(final_chromosome[idx] - step_size, first(range), last(range))
        down_f = Embryo(down_chromosome, fitness_function).f_value

        if up_f < f_value || down_f < f_value
            if up_f <= down_f
                direction = 1.0
                f_value = up_f
                final_chromosome = up_chromosome
            else
                direction = -1.0
                f_value = down_f
                final_chromosome = down_chromosome
            end

            iterations = 0
            while iterations < max_generations
                new_chromosome = copy(final_chromosome)
                new_chromosome[idx] = clamp(new_chromosome[idx] + direction * step_size, first(range), last(range))
                new_f = Embryo(new_chromosome, fitness_function).f_value
                if new_f < f_value
                    f_value = new_f
                    final_chromosome = new_chromosome
                    iterations += 1
                else
                    break
                end
            end
        end
    end

    return final_chromosome
end

function local_search(offspring, fitness_function, mutation_rate, range, caste)
    return offspring
end