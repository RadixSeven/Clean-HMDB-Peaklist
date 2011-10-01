#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

########################
# Checks that no files have a line that starts with "list"
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
    my $no_list_of = ($contents !~ m/^list/mi);
    ok($no_list_of, "$file has no lines that start with \"list\"");
}
