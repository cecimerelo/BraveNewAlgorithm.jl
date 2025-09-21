#!/usr/bin/env perl

use strict;
use warnings;

use v5.14;

use lib qw(lib ../lib ../../lib);
use Utils qw(process_pinpoint_output);

my $preffix = shift || die "I need a prefix for the data files";
my $data_dir = shift || "data";
my $function = shift || "bna";

my $ITERATIONS = 30;
my ($mon,$day,$hh,$mm,$ss) = localtime() =~ /(\w+)\s+(\d+)\s+(\d+)\:(\d+)\:(\d+)/;
my $suffix = "$day-$mon-$hh-$mm-$ss";

open my $fh, ">", "$data_dir/$preffix-$function-$suffix.csv";
say $fh "work,type,size,max_gens,alpha,PKG,seconds,generations,diff_fitness,evaluations";

for my $t ( qw(3 5) ) {
  for my $l ( qw(200 400) ) {
    for my $max_gens ( qw(10 50) ) {
      for my $alpha ( qw(10 25) ) {
        my $total_seconds;
        my $successful = 0;
        my @results;
        do {
          my $command = "/home/jmerelo/.juliaup/bin/julia examples/simple_test.jl $t $l $max_gens $alpha";
          say $command;
          my $output = `pinpoint -- $command 2>&1`;
          say $output;
          my ( $gpu, $pkg, $seconds ) = process_pinpoint_output $output;
          if ($gpu != 0 ) {
            $successful++;
            $total_seconds += $seconds;
            say "$preffix, $function, $t,  $l,$pkg, $seconds";
            my ($generations, $best_fitness, $target_fitness, $evaluations ) = process_bna_output( $output );
            push @results, [$pkg,$seconds,$generations, $best_fitness-$target_fitness , $evaluations];
          }
        } while ( $successful < $ITERATIONS );

        foreach  my $row (@results) {
          say join(", ", @$row);
          say $fh "$function, $t, $l, $max_gens, $alpha, ", join(", ", @$row);
        }
      }
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
