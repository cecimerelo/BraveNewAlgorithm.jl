#!/usr/bin/env perl

use strict;
use warnings;

use v5.14;

use lib qw(lib ../lib ../../lib);
use Utils qw(process_pinpoint_output);

my $preffix = shift || die "I need a prefix for the data files";
my $function = shift || "bna";
my $ITERATIONS = 30;

my $data_dir = "data";

my ($mon,$day,$hh,$mm,$ss) = localtime() =~ /(\w+)\s+(\d+)\s+(\d+)\:(\d+)\:(\d+)/;
my $suffix = "$day-$mon-$hh-$mm-$ss";

open my $fh, ">", "$data_dir/$preffix-$function-$suffix.csv";
say $fh "work,dimension,population_size,max_gens,alpha,PKG,seconds,generations,diff_fitness,evaluations";

my $alpha = 10;
for my $t ( qw(10 5 3) ) {
  for my $l ( qw(400 200) ) {
    for my $max_gens ( qw(10 25) ) {
      for ( my $i = 0; $i < $ITERATIONS; $i++ ) {
        for my $baseline ( qw( 1 0 ) ) {
          run_command_for_preffix( $fh, $t, $l, $max_gens, $baseline );
        }
      }
      run_command_for_preffix( $fh, $t, $l, $max_gens, 1 );
    }
  }
}

close $fh;

sub process_bna_output {
  my $output = shift;
  my ($generations, $best_fitness, $target_fitness, $evaluations ) =
    $output =~ /generations:\s+(\d+).+Best fitness: (\S+).+fitness: (\S+).+evaluations: (\d+)/s;
  return $generations, $best_fitness, $target_fitness, $evaluations
}

sub run_command_for_preffix {
  my ($fh, $t, $l, $max_gens, $baseline) = @_;
  my $pre_preffix = ($baseline eq "1")?"base-" : "";
  say "\nRunning $pre_preffix";
  my ( $gpu, $pkg, $seconds, $output );
  my $command = "/home/jmerelo/.juliaup/bin/julia examples/BBOB_sphere_with_baseline.jl $t $l $max_gens $alpha".($baseline ? " 1" : "");
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
  say $fh "$pre_preffix$function, $t, $l, $max_gens, $alpha, ", join(", ", @results);
}
