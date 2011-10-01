#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

########################
# Checks that the HNMR table header (for tables with a header)
# starts as would be expected
########################

#List of files to check
my @files = glob("../NMR_Peaklist/HMDB*.txt");


#We will perform three tests for each file
plan tests=>scalar(@files);


#States of the table-recognizing state-machine.
sub NOT_IN_HNMR(){ 0 };
sub OUTSIDE_TABLE(){ 1 };
sub SEEN_TABLE(){ 2 };

foreach my $file (@files){
    open(my $fh, "<", $file) or die "Could not open $file";
    my $table_state = NOT_IN_HNMR;
    my $table_type = ""; #The string after "Table of " in the table start line
    my $sep = ""; #separator - space or tab
    my $HNMR_section_regex = qr/^.*HNMR.*[Pp]eaklists?:?\s*$/;
    
    #Error variables recording if there was an error in the entire file
    my $bad_text = "";      #Line that should have been a header
    my $bad_line_num = -1;  #Line number on which the field was found
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
	    #Anything is acceptable.  At "Table of
	    #(Multiplets|Assignments|Peaks|Experiment Metadata)", goes to next state, at
	    #$HNMR_section_regex stays in same state.  At any other #
	    #started line, goes back to NOT_IN_HNMR
	    if     (m/^Table of (Multiplets|Assignments|Peaks|Experiment Metadata)$/){
		$table_state = SEEN_TABLE;
		$table_type = $1;
	    }elsif (m/^Table of/){
		diag("WARNING: Ignoring table of unknown type \"$_\" in ".
		     "line $. of $file ");
	    }elsif (m/$HNMR_section_regex/){
	    }elsif (m/^#/){
		$table_state = NOT_IN_HNMR;
	    }
	    next;
	}elsif ($table_state == SEEN_TABLE){
	    #Header
	    if ($table_type =~ qr/Multiplets|Assignments|Peaks/){
		if (m/^No\.([ \t])[A-z.()]/){ #Multiplets, Assignments and
					  #Peaks all start with "No."
		    $table_state = OUTSIDE_TABLE;
		    next;
		}
	    }elsif ($table_type =~ qr/Experiment Metadata/){
		if ($_ !~ qr/^\s*$/){
		    $table_state = OUTSIDE_TABLE;
		    next;
		}
	    }
	    $bad_text = $_;
	    $bad_line_num = $.;
	    last;
	    
	};
    }
    ok($bad_line_num == -1, "$file has recognizable table headers");
    unless($bad_line_num == -1){
	diag("Line $bad_line_num contained ".
	     "'$bad_text'");
    }
}
