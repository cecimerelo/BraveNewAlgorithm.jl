@views function crossover_operator(parents, cache1, cache2)
    chromosome_length = length(parents[1].chromosome)
    if length(parents[1].chromosome) != length(parents[2].chromosome)
        throw(ArgumentError("The length of the parents[1] chromosome ($(length(parents[1].chromosome))) is different from the length of the parents[2] chromosome ($(length(parents[2].chromosome)))"))
    end

    start_of_the_segment = rand(1:chromosome_length-1)
    segment_length = rand(1:chromosome_length-start_of_the_segment)
    end_of_segment = start_of_the_segment + segment_length

    segment = start_of_the_segment:end_of_segment
    offspring1 = cache1
    offspring2 = cache2
    # offspring = Matrix{Float64}(undef,chromosome_length,2)
    @inbounds for i in eachindex(offspring1,offspring2)
        @inbounds if i in segment
            offspring1[i] = parents[2].chromosome[i]
            offspring2[i] = parents[1].chromosome[i] 
        end
        offspring1[i] = parents[1].chromosome[i]
        offspring2[i] = parents[2].chromosome[i]
    end
    return (offspring1, offspring2)
end