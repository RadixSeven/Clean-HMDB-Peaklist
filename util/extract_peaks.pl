#!/usr/bin/perl
use strict;
use warnings;

################
# Print the peak ppms in an HMDB peaklist file.  Modified from
# extract_peak_headers.pl
#
# Usage: extract_peaks HMDB_peaklist_file.txt

#usage: indexOrNeg1=find_first(regex, array_ref);
#
#Returns the index of the first matching element in the array or -1 if
#there is no such element
sub find_first($$){
    my ($regex, $array_ref) = @_;
    for my $i (0..$#$array_ref){
	return $i if ($array_ref->[$i] =~ m/$regex/);
    }
    return -1;
}

for my $fn (@ARGV){
    open(my $fh, '<', $fn) or die $!;
    #Indices of the various fields
    my $num_idx=-1;
    my $ppm_idx = -1;
    while(<$fh>){
	#Remove whitespace
	chomp;

	#Skip rest of file after first blank line
	last if (m/^\s*$/); 

	#If this is the header line
	if (m/^No./){ 
	    #Split the header
	    my $has_tabs = m/\t/;
	    my @fields;
	    if ($has_tabs){
		@fields = split /\t/;
	    }else{
		@fields = split;
	    }
	    $num_idx = 0;
	    $ppm_idx = find_first(qr/ppm/i,\@fields);
	#If this is the expected table header or a comment, skip it
	}elsif (m/^#/ || m/^Table of Peaks/i){
	#Otherwise, we expect a line with just numbers and spaces
	}else{
	    die "Should not run into another table in file $fn. Offending line:\n$_\n" if m/table/i;
	    my @fields = split;
	    print "$fields[$num_idx],$fields[$ppm_idx]\n";
	}
    }
}
