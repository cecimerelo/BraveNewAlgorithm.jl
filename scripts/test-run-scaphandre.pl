#!/usr/bin/env perl
use strict;
use warnings;
use v5.14;
  

# Constants
my $SAMPLING_TIME = 1.0; # seconds
my $TARGET_PROCESS = "julia";

# Usage: perl scripts/parse_energy.pl <file>
my $temp_file_name =  '/tmp/scaphandre-test.txt';

say "Energy; seconds";
for (my $iteration = 0; $iteration < 30; $iteration++ ) {
  # Run command
  `sudo  /home/jmerelo/.juliaup/bin/julia examples/BBOB_sphere_with_baseline.jl 40 10000 50 10 256 >/dev/null 2>&1  & sudo time scaphandre stdout -s 1 -p 10  > $temp_file_name 2>&1`;
  open(my $fh, '<', $temp_file_name) or die "Could not open file '$temp_file_name': $!";

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
    say "$total_energy; $elapsed_time";
  }
}


