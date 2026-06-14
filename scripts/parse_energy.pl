#!/usr/bin/env perl
use strict;
use warnings;

# Constants
my $SAMPLING_TIME = 1.0; # seconds
my $TARGET_PROCESS = "julia";

# Usage: perl scripts/parse_energy.pl <file>
my $file = $ARGV[0] || 'data/scaphandre-test.txt';

open(my $fh, '<', $file) or die "Could not open file '$file': $!";

my @power_samples;
my $last_found_power = 0;
my $elapsed_time = 0;

while (my $line = <$fh>) {
    # Extract power for the target process
    if ($line =~ /([\d\.]+) W\s+\d+\s+".*$TARGET_PROCESS.*"/) {
        my $power = $1;
        push @power_samples, $power;
        $last_found_power = $power;
    }
    # Extract elapsed time from the time command output (format M:SS.mmm)
    if ($line =~ /(\d+):([\d\.]+)elapsed/) {
        $elapsed_time = ($1 * 60) + $2;
    }
}
close($fh);

# Calculate total energy
my $total_energy = 0;

if (@power_samples > 0) {
    # Sum energy for all full samples
    for my $i (0 .. $#power_samples - 1) {
        $total_energy += $power_samples[$i] * $SAMPLING_TIME;
    }

    # Handle the last fraction of time
    my $full_samples_count = @power_samples;
    my $remaining_fraction = $elapsed_time - ($full_samples_count - 1) * $SAMPLING_TIME;

    if ($remaining_fraction > 0) {
        $total_energy += $last_found_power * $remaining_fraction;
    } else {
        $total_energy += $last_found_power * $SAMPLING_TIME;
    }
}

print "Total Energy: $total_energy Joules\n";
