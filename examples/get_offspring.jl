using .BraveNewAlgorithm
include("../src/operators/crossover.jl")

function get_offspring(embryos)
    all_offspring = []
    for i in 1:2:length(embryos)-1
        j = i + 1
        @info typeof(ALPHA())
        parents = (
            Individual(embryos[i].chromosome, embryos[i].f_value, ALPHA()),
            Individual(embryos[j].chromosome, embryos[j].f_value, ALPHA())
        )

        offspring = crossover_operator(parents)
        push!(all_offspring, offspring[1])
        push!(all_offspring, offspring[2])
    end
    return all_offspring
end
