function crossover_operator(parents)
    chromosome_length = length(parents[1].chromosome)
    if length(parents[1].chromosome) != length(parents[2].chromosome)
        throw(ArgumentError("The length of the parents[1] chromosome ($(length(parents[1].chromosome))) is different from the length of the parents[2] chromosome ($(length(parents[2].chromosome)))"))
    end

    start_of_the_segment = rand(1:chromosome_length-1)
    segment_length = rand(1:chromosome_length-start_of_the_segment)

    end_of_segment = start_of_the_segment + segment_length - 1
    indexes_to_take_from_parent = [mod(index, chromosome_length) + 1 for index in start_of_the_segment:end_of_segment]

    offspring1 = Array{Float64,1}()
    offspring2 = Array{Float64,1}()
    for index in 1:chromosome_length
        if index in indexes_to_take_from_parent
            insert!(offspring1, index, parents[1].chromosome[index])
            insert!(offspring2, index, parents[2].chromosome[index])
        else
            insert!(offspring1, index, parents[2].chromosome[index])
            insert!(offspring2, index, parents[1].chromosome[index])
        end
    end

    return (offspring1, offspring2)
end