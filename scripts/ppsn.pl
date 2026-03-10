#!/usr/bin/env perl

use strict;
use warnings;

use v5.14;

use lib qw(lib ../lib ../../lib);
use Utils qw(process_pinpoint_output process_sensors_output);

my $preffix = shift || die "I need a prefix for the data files";
my $function = shift || "bna";
my $ITERATIONS = 30;

my $data_dir = "data";

my ($mon,$day,$hh,$mm,$ss) = localtime() =~ /(\w+)\s+(\d+)\s+(\d+)\:(\d+)\:(\d+)/;
my $suffix = "$day-$mon-$hh-$mm-$ss";

my @tasksets = ( "0-7,16-23","8-15,24-31");

open my $fh, ">", "$data_dir/$preffix-$function-$suffix.csv";
say $fh "work,dimension,population_size,max_gens,alpha,steps,PKG,seconds,generations,diff_fitness,evaluations,initial_temp_1, initial_temp_2, final_temp_1, final_temp_2";

my $JULIA_PATH = "/home/jmerelo/.juliaup/bin/julia";

my $dimension = 10;
for my $alpha ( qw(10 25) ) {
  for my $l ( qw(400 800) ) {
    for my $max_gens ( qw(10 25) ) {
      for my $steps ( qw( 16 64) ) {
        for ( my $i = 0; $i < $ITERATIONS; $i++ ) {
          for my $baseline ( qw( 1 0 ) ) {
            run_command_for_preffix( $fh, $dimension, $l, $alpha, $max_gens, $steps, $baseline );
          }
        }
        run_command_for_preffix( $fh, $dimension, $l, $alpha, $max_gens, $steps, 1 );
      }
    }
  }
}

close $fh;

sub run_sensors {
  my $output = `sensors`;
  return process_sensors_output( $output );
}

sub process_bna_output {
  my $output = shift;
  my ($generations, $best_fitness, $target_fitness, $evaluations ) =
    $output =~ /generations:\s+(\d+).+Best fitness: (\S+).+fitness: (\S+).+evaluations: (\d+)/s;
  return $generations, $best_fitness, $target_fitness, $evaluations
}

sub run_command_for_preffix {
  my @initial_temperature = run_sensors();
  my ($fh, $t, $l, $alpha, $max_gens, $steps, $baseline) = @_;
  my $this_taskset = $initial_temperature[0] > $initial_temperature[1]?$tasksets[0]:$tasksets[1];
  my $pre_preffix = ($baseline eq "1")?"base-" : "";
  my ( $gpu, $pkg, $seconds, $output );
  my $command = "taskset -c $this_taskset $JULIA_PATH examples/BBOB_sphere_with_baseline.jl $t $l $max_gens $alpha $steps".($baseline ? " 1" : "");
  say $command;
  do {
    $output = `pinpoint -i 100 -- $command 2>&1`;
    say $output;
    ( $gpu, $pkg, $seconds ) = process_pinpoint_output $output;
  } while ( $gpu == 0 );
  say "$pre_preffix$preffix, $function, $t,  $l,$pkg, $seconds";
  my ($generations, $best_fitness, $target_fitness, $evaluations ) = process_bna_output( $output );
  my @results = ($pkg,$seconds,$generations, $best_fitness-$target_fitness, $evaluations);
  say join(", ", @results);
  
  my @final_temperature = run_sensors();
  say $fh "$pre_preffix$function, $t, $l, $max_gens, $alpha, $steps, ",
            join(", ", @results), ", ",
            join(", ", @initial_temperature), ", ",
            join(", ", @final_temperature);

}
