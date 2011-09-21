#!/usr/bin/perl
use strict;
use warnings;

################
# Print the extracted fields of the header line for the Table of Peaks
# in an HMDB peaklist file
#
# Usage: extract_peak_headers HMDB_peaklist_file.txt

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
    my $height_idx = -1;
    my $hz_idx = -1;
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
	    $height_idx = find_first(qr/height/i,\@fields);
	    $hz_idx = find_first(qr/hz/i,\@fields);

	    print "\"$fn\"";
	    print "\t$fields[$num_idx]" if $num_idx >= 0;
	    print "\t$fields[$ppm_idx]" if $ppm_idx >= 0;
	    print "\t$fields[$height_idx]" if $height_idx >= 0;
	    print "\t$fields[$hz_idx]" if $hz_idx >= 0;
	    print "\n";
	}
    }
}
