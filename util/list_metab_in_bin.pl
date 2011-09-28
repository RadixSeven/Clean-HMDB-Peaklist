#!/usr/bin/perl
use strict;
use warnings;

##################
# Usage: list_metab_in_bin.pl bin_width < peak_ppms
#
# Reads a list of peak ppms (the output of extract_peak_ppms) from
# stdin and lists the metabolites in each bin if the bins are
# bin_width wide.  It prints the results to stdout.

my $bin_width = shift;

my $max_ppm; #Max ppm of any peak of any metabolite

#Read in the metabolites
my @metabolites; #Each entry is the ppm values for a metabolite
while(<STDIN>){
    chomp;
    my @ppms = split(qr/\t/);
    my %metab = ();
    $metab{"name"}= shift @ppms;
    for my $ppm (@ppms){
	if(!defined($max_ppm) || $ppm > $max_ppm){
	    $max_ppm = $ppm;
	}
    }
    $metab{"ppms"}= \@ppms;
    push @metabolites, \%metab;
}

#Print bin contents
my $spectrum_start = -1; #Lower bound of the first bin
my $bin_num = 0; #Number of the current bin
my $bin_lb = $spectrum_start+$bin_num*$bin_width; #Bin lower bound

while($bin_lb <= $max_ppm){
    #Count the metabolites in the current bin
    my $bin_ub = $bin_lb + $bin_width;
    my @metab_list;
    METABOLITE: foreach my $metab (@metabolites){
	my $name = $$metab{"name"};
	my $ppms = $$metab{"ppms"};
	foreach my $ppm (@$ppms){
	    if($bin_lb <= $ppm && $ppm < $bin_ub){
		push @metab_list, $name;
		next METABOLITE;
	    }
	}
    }

    #Print
    printf "%2.3f\t%2.3f\t%s\n",$bin_lb,$bin_ub,join("\t",@metab_list);

    #Next bin
    ++$bin_num;
    $bin_lb = $spectrum_start+$bin_num*$bin_width; #Bin lower bound
}

