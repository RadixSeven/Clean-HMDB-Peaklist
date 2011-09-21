#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

########################
# Checks that all files that have a proton NMR table of peaks have a
# header that says "Table of Peaks".  
#
# A list of HMDB ids without such a peak list is kept in
# ../metadata/entries_without_h_nmr_peak_table.txt.  Lines in that file
# that are blank or that start with a # first character are considered
# to be a comment.
########################

#Return a hash with the names of files without a peak table mapped to
#1 and no other keys
sub files_without_peak_table(){
    open my $in, "<", "../metadata/entries_without_h_nmr_peak_table.txt";
    my @entries = <$in>;
    my %files = ();
    for my $id (@entries){
	unless($id =~ m/^#/ || $id =~ m/^\s*$/){
	    chomp $id;
	    my $name = "../NMR_Peaklist/${id}_NMR_peaklist.txt";
	    $files{$name}=1;
	}
    }
    return %files;
}

#Set up the list of files that ought to have a peak table in @files
my @initial_files = glob("../NMR_Peaklist/HMDB*.txt");
my %no_table = files_without_peak_table;

my @files = ();
foreach my $file (@initial_files){
    push @files, $file unless $no_table{$file};
}


#We will perform one test for each member of the list of files
plan tests=>scalar(@files);

#Read in each file
foreach my $file (@files){
    open my $fh, "<", $file;
    my $has_table_header = 0;
    while(<$fh>){
	chomp;
	$has_table_header = 1 if m/^Table of Peaks$/;
    }
    ok($has_table_header, "$file has a line that says \"Table of Peaks\"");
}
