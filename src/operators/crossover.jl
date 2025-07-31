function crossover_operator(parents)
    chromosome_length = length(parents[1].chromosome)
    if length(parents[1].chromosome) != length(parents[2].chromosome)
        throw(ArgumentError("The length of the parents[1] chromosome ($(length(parents[1].chromosome))) is different from the length of the parents[2] chromosome ($(length(parents[2].chromosome)))"))
    end

    start_of_the_segment = rand(1:chromosome_length-1)
    segment_length = rand(1:chromosome_length-start_of_the_segment)
    end_of_segment = start_of_the_segment + segment_length

    segment = start_of_the_segment:end_of_segment

    offspring1 = copy(parents[1].chromosome)
    offspring2 = copy(parents[2].chromosome)
    offspring1[segment] .= parents[2].chromosome[segment]
    offspring2[segment] .= parents[1].chromosome[segment]

    return (offspring1, offspring2)
end