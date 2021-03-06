#!/usr/bin/perl
use strict;
use warnings;

#####
# Usage: remove_tab_adjacent_spaces.pl file1 file2 file3
#
# The files will be modified and so that there are no space characters
# that are next to tabs.
#####

for my $file (@ARGV){
    my $contents;
    {
	local( $/ );
	open(my $fh, "<", $file) or die "Could not read $file: $!";
	binmode($fh);
	$contents = <$fh>;
    }
    
    my $num_replacements = $contents =~ s/ +\t +| +\t|\t +/\t/g;
    if ($num_replacements > 0){
	open(my $fh, ">", $file) or die "Could not write $file: $!";
	binmode($fh);
	print $fh $contents;
    }
}
