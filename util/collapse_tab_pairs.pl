#!/usr/bin/perl
use strict;
use warnings;

#####
# Usage: collapse_tab_pairs.pl file1 file2 file3 ...
#
# The files will be modified so every pair of adjacent tabs is
# replaced by one tab.
#####

for my $file (@ARGV){
    my $contents;
    {
	local( $/ );
	open(my $fh, "<", $file) or die "Could not read $file: $!";
	binmode($fh);
	$contents = <$fh>;
    }
    
    my $num_replacements = $contents =~ s/\t\t/\t/g;
    if ($num_replacements > 0){
	open(my $fh, ">", $file) or die "Could not write $file: $!";
	binmode($fh);
	print $fh $contents;
    }
}
