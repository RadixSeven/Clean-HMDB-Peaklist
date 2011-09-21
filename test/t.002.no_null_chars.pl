#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

########################
# Checks that no files have an ascii null character
########################

#List of files to check
my @files = glob("../NMR_Peaklist/HMDB*.txt");



#We will perform one test for each file
plan tests=>scalar(@files);

#Read in each file
foreach my $file (@files){
    my $contents;
    {
	local( $/ );
	open(my $fh, "<", $file) or die "Could not open $file";
	binmode($fh);
	$contents = <$fh>;
    }
    my $no_null = ($contents !~ m/\x00/);
    ok($no_null, "$file is free of null characters");
}
