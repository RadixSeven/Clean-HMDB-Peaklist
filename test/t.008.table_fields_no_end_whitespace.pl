#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

########################
# Checks that the HNMR table header fields (for tables with a header)
# have no leading or trailing whitespace and are non-empty
########################

#List of files to check
my @files = glob("../NMR_Peaklist/HMDB*.txt");


#We will perform one test for each file
plan tests=>scalar(@files);


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

#States of the table-recognizing state-machine.
sub NOT_IN_HNMR(){ 0 };
sub OUTSIDE_TABLE(){ 1 };
sub SEEN_TABLE(){ 2 };

foreach my $file (@files){
    open(my $fh, "<", $file) or die "Could not open $file";
    my $table_state = NOT_IN_HNMR;
    my $sep = ""; #separator - space or tab
    my $HNMR_section_regex = qr/^.*HNMR.*[Pp]eaklists?:?\s*$/;
    
    #Error variables recording if there was an error in the entire file
    my $bad_field = ""; #Contents of the whitespace surrounded field
    my $bad_line = -1;  #Line number on which the field was found
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
	    #(Multiplets|Assignments|Peaks)", goes to next state, at
	    #$HNMR_section_regex stays in same state.  At any other #
	    #started line, goes back to NOT_IN_HNMR
	    if     (m/^Table of (Multiplets|Assignments|Peaks)$/){
		$table_state = SEEN_TABLE;
	    }elsif (m/$HNMR_section_regex/){
	    }elsif (m/^#/){
		$table_state = NOT_IN_HNMR;
	    }
	    next;
	}elsif ($table_state == SEEN_TABLE){
	    #Header
	    if (m/^\S*([ \t])/){
		$sep = $1;
		my @fields = split(qr/$sep/);
		my $non_ws_idx = find_first(qr/^\s+\S+|\S+\s+$|^\s*$/,\@fields);
		unless ( $non_ws_idx == -1){
		    $bad_field = $fields[$non_ws_idx];
		    $bad_line = $.;
		    last;
		}
		$table_state = OUTSIDE_TABLE;
		next;
	    }else{
		die "All files should have a header right after Table of ...";
	    }
	};
    }
    ok($bad_line == -1, "Table fields in $file are non-empty and ".
       "have no white-space before or after.") 
	or
	diag("The last bad field was on line $bad_line and contained ".
	     "'$bad_field'");
    
}
