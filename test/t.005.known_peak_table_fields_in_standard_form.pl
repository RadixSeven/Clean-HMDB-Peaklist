#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

########################
# Checks that the known fields in HNMR "Table of Peaks" header are in
# standard form if present.  Checks that No. and ppm are present.
########################

#List of files to check
my @files = glob("../NMR_Peaklist/HMDB*.txt");


#We will perform three tests for each file
plan tests=>3*scalar(@files);


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
    my $all_headers_had_ppm = 1; #True if all Table of Peaks headers
				 #detected had a (ppm) field.
    my $no_ppm_line = -1; #Last file line number on which there was no
			  #ppm field
    my $all_headers_had_no = 1; #This should never be false given the
				 #way I detect the header but I'll
				 #test it anyway, in case the header
				 #test changes down the road.
    my $no_no_line = -1; #Last file line number on which there was no
			 #No. field
    my $expected_field = ""; #Set to the expected form when a
			     #non-standard field name encountered
    my $got_field = ""; #Set to what was gotten when there is a
			#non-standard field name
    my $non_standard_line = -1; #The last file line number on which
				#there was a non-standard known field
    
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
	    #Anything is acceptable.  At "Table of Peaks", goes to
	    #next state, at $HNMR_section_regex stays in same state.
	    #At any other # started line, goes back to NOT_IN_HNMR
	    if     (m/^Table of Peaks$/){
		$table_state = SEEN_TABLE;
	    }elsif (m/$HNMR_section_regex/){
	    }elsif (m/^#/){
		$table_state = NOT_IN_HNMR;
	    }
	    next;
	}elsif ($table_state == SEEN_TABLE){
	    #Must have "^No\.([ \t])[A-z.()]" to be acceptable as a header
	    if (m/^No\.([ \t])[A-z.()]/){
		$sep = $1;
		my @fields = split(qr/$sep/);
		my $idx_height = find_first(qr/height/i,\@fields);
		my $idx_ppm = find_first(qr/ppm/i,\@fields);
		my $idx_no = find_first(qr/no\./i,\@fields);
		my $idx_hz = find_first(qr/hz/i,\@fields);
		if ($idx_height != -1){
		    if (find_first(qr/^Height$/,\@fields) == -1){
			$expected_field = "Height";
			$got_field = $fields[$idx_height];
			$non_standard_line = $.;
		    }
		}
		if ($idx_hz != -1){
		    if (find_first(qr/^\(Hz\)$/,\@fields) == -1){
			$expected_field = "(Hz)";
			$got_field = $fields[$idx_hz];
			$non_standard_line = $.;
		    }
		}
		if ($idx_ppm != -1){
		    if (find_first(qr/^\(ppm\)$/,\@fields) == -1){
			$expected_field = "(ppm)";
			$got_field = $fields[$idx_ppm];
			$non_standard_line = $.;
		    }
		}else{
		    $all_headers_had_ppm = 0;
		    $no_ppm_line = $.;		    
		}
		if ($idx_no != -1){
		    if (find_first(qr/^No\.$/,\@fields) == -1){
			$expected_field = "No.";
			$got_field = $fields[$idx_no];
			$non_standard_line = $.;
		    }
		}else{
		    $all_headers_had_no = 0;
		    $no_no_line = $.;		    
		}
		
		$table_state = OUTSIDE_TABLE;
		next;
	    }else{
		die "All files should have a header right after Table of Peaks";
	    }
	};
    }
    is($got_field, $expected_field, "$file had all Table of Peaks ".
       "header fields in standard form.");
    if($got_field ne $expected_field){
	diag("Last non-standard header was on line $non_standard_line");
    }
    ok($all_headers_had_ppm, "All Table of Peaks headers in $file had a ".
       "ppm field.");
    unless($all_headers_had_ppm){
	diag("Last header without a ppm field was on line $no_ppm_line");
    }
    ok($all_headers_had_no, "All Table of Peaks headers in $file had a ".
       "No. field.");
    unless($all_headers_had_no){
	diag("Last header without a No. field was on line $no_no_line");
    }
}
