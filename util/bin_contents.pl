#!/usr/bin/perl
use strict;
use warnings;

##################
# Usage: bin_contents.pl bin_width [metab*| peak*] < peak_ppms
#
# Reads a list of peak ppms (the output of extract_peak_ppms) from
# stdin and counts the contents of each bin if the bins are bin_width
# wide.  If the second argument matches metab*, it counts the number
# of metabolites with a peak in that bin.  If the second argument
# matches peak*, it counts the number of peaks lying in that bin.  It
# prints the results to stdout.

my $bin_width = shift;
my $second_arg = shift;

my $to_count;
sub COUNT_METAB(){ 0 }
sub COUNT_PEAK(){ 1 }
if ($second_arg =~ /^metab/i){
    $to_count = COUNT_METAB;
}elsif ($second_arg =~ /^peak/i){
    $to_count = COUNT_PEAK;
}else{
    print STDERR "The second argument must start with metab or with peak\n";
    exit(-1);
}

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

if($to_count == COUNT_METAB){
    print "Bin Lower\tBin Upper\tNum Metabolites\n"; # Print header
}else{
    print "Bin Lower\tBin Upper\tNum Peaks\n"; # Print header
}
while($bin_lb <= $max_ppm){
    #Count the metabolites in the current bin
    my $bin_ub = $bin_lb + $bin_width;
    my $count = 0;
    METABOLITE: foreach my $ppms (@metabolites){
	foreach my $ppm (@$ppms){
	    if($bin_lb <= $ppm && $ppm < $bin_ub){
		++$count;
		if($to_count == COUNT_METAB){
		    next METABOLITE;
		}
	    }
	}
    }

    #Print
    printf "%2.3f\t%2.3f\t%d\n",$bin_lb,$bin_ub,$count;

    #Next bin
    ++$bin_num;
    $bin_lb = $spectrum_start+$bin_num*$bin_width; #Bin lower bound
}

