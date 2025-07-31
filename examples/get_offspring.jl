include("../src/operators/crossover.jl")

function get_offspring(embryos)
    r = 1:2:length(embryos)-1
    all_offspring = Vector{Vector{Float64}}(undef,2*length(r))
    c = 1
    cache1 = zeros(length(embryos[1].chromosome))
    cache2 = zeros(length(embryos[1].chromosome))
    for i in 1:2:length(embryos)-1
        j = i + 1
        parents = (
            Individual(embryos[i].chromosome, embryos[i].f_value, ALPHA()),
            Individual(embryos[j].chromosome, embryos[j].f_value, ALPHA())
        )
        offspring = crossover_operator(parents, cache1, cache2)
        all_offspring[c] = offspring[1]
        all_offspring[c+1] = offspring[2]
        c += 2
    end
    return all_offspring
end
