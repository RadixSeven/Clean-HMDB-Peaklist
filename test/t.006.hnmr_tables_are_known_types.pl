#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

########################
# Checks that the all HNMR "Table of" lines are for known table types
# (also catches incorrectly capitalized lines)
########################

#List of files to check
my @files = glob("../NMR_Peaklist/HMDB*.txt");


#We will perform three tests for each file
plan tests=>scalar(@files);


#States of the table-recognizing state-machine.
sub NOT_IN_HNMR(){ 0 };
sub OUTSIDE_TABLE(){ 1 };

FILE: foreach my $file (@files){
    open(my $fh, "<", $file) or die "Could not open $file";
    my $table_state = NOT_IN_HNMR;
    my $HNMR_section_regex = qr/^.*HNMR.*[Pp]eaklists?:?\s*$/;
    
    while(<$fh>){
	chomp;
	if    ($table_state == NOT_IN_HNMR){
	    #Anything is acceptable.  A $HNMR_section_regex line goes
	    #to OUTSIDE_TABLE
	    if (m/$HNMR_section_regex/){
		$table_state = OUTSIDE_TABLE;
	    }
	    next;
	}elsif ($table_state == OUTSIDE_TABLE){
	    #Any "Table of" except "Table of
	    #(Multiplets|Assignments|Peaks|Experiment Metadata)",
	    #fails and goes to the next file.  $HNMR_section_regex
	    #stays in same state.  At any other # started line, goes
	    #back to NOT_IN_HNMR
	    if     (m/^Table of (Multiplets|Assignments|Peaks|Experiment Metadata)$/){
	    }elsif (m/^Table of/i){
		fail("All tables in $file are known types");
		diag("Bad table type line \"$_\" in line $. of $file ");
		next FILE;
	    }elsif (m/$HNMR_section_regex/){
	    }elsif (m/^#/){
		$table_state = NOT_IN_HNMR;
	    }
	    next;
	};
    }
    pass("All tables in $file are known types");
}
