#!/bin/bash

# Check if prefix is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <prefix>"
    echo "Example: $0 single_crossover_results_"
    exit 1
fi

PREFIX=$1
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${PREFIX}-${TIMESTAMP}.txt"

# Create the output file with header
echo "Results of multiple runs - $(date)" > "$OUTPUT_FILE"
echo "Command: pinpoint /home/jmerelo/.juliaup/bin/julia examples/single_only_crossover.jl" >> "$OUTPUT_FILE"
echo "===" >> "$OUTPUT_FILE"

# Run the command 30 times
echo "Running 30 iterations..."
for i in $(seq 1 30); do
    echo "=== Run $i ===" >> "$OUTPUT_FILE"
    pinpoint /home/jmerelo/.juliaup/bin/julia examples/single_only_crossover.jl >> "$OUTPUT_FILE" 2>&1
    echo "===" >> "$OUTPUT_FILE"
done

echo "Results saved to: $OUTPUT_FILE"
