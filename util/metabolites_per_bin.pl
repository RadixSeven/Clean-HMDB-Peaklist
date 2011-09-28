#!/usr/bin/perl
use strict;
use warnings;

##################
# Usage: metabolites_per_bin.pl bin_width < peak_ppms
#
# Reads a list of peak ppms (the output of extract_peak_ppms) from
# stdin and counts the number of metabolites falling in each bin if
# the bins are bin_width wide.  It prints the results to stdout.

my $bin_width = shift;
my $verbose = @ARGV != 0;
my $max_ppm; #Max ppm of any peak of any metabolite

#Read in the metabolites
my @metabolites;
while(<STDIN>){
    chomp;
    my @ppms = split(qr/\t/);
    shift @ppms;
    for my $ppm (@ppms){
	if(!defined($max_ppm) || $ppm > $max_ppm){
	    $max_ppm = $ppm;
	}
    }
    push @metabolites, \@ppms;
}

#Total the bins and print them
my $spectrum_start = -1; #Lower bound of the first bin
my $bin_num = 0; #Number of the current bin
my $bin_lb = $spectrum_start+$bin_num*$bin_width; #Bin lower bound

print "Bin Lower\tBin Upper\tNum Metabolites\n"; # Print header
while($bin_lb <= $max_ppm){
    #Count the metabolites in the current bin
    my $bin_ub = $bin_lb + $bin_width;
    my $count = 0;
    METABOLITE: foreach my $ppms (@metabolites){
	foreach my $ppm (@$ppms){
	    if($bin_lb <= $ppm && $ppm < $bin_ub){
		++$count;
		next METABOLITE;
	    }
	}
    }

    #Print
    printf "%2.3f\t%2.3f\t%d\n",$bin_lb,$bin_ub,$count;

    #Next bin
    ++$bin_num;
    $bin_lb = $spectrum_start+$bin_num*$bin_width; #Bin lower bound
}

