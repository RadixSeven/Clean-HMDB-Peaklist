#!/usr/bin/perl
use strict;
use warnings;

########################
#
# Usage: extract_peak_ppms.pl file1 file2 ...
#
# Takes a list of HMDB peaklist files on the command line (the name is
# assumed to contain the HMDB ID number) and for each file prints the
# ID number followed by a tab and the string 'ppm', another tab and
# then the tab-separated list of the ppms of the peaks in the first
# "Table of Peaks" entry in the HNMR section of the file.  The printed
# ppms are followed by a newline.  It also prints the corresponding
# peak heights on a line with the HMDB ID a tab and the string
# 'heights' and the tab-separated heights. If there is no table of
# peaks or no HNMR section, does nothing.
########################

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
sub SEEN_HEADER(){ 3 };
sub SEEN_DATA_LINE(){ 4 };


FILE: foreach my $file (@ARGV){
    open(my $fh, "<", $file) or die "Could not open $file";
    my $table_state = NOT_IN_HNMR;
    my $sep = ""; #separator - space or tab
    my $idx_ppm = -1; #The index of the ppm field in the table
    my $idx_height = -1; #The index of the height field in the table
    my $HNMR_section_regex = qr/^.*HNMR.*[Pp]eaklists?:?\s*$/;
    my @ppms = (); #Holds the collected ppm values for this file
    my @heights = (); #Holds the collected height values for this file
    
    while(<$fh>){
	chomp;
	if    ($table_state == NOT_IN_HNMR){
	    #Read until you find a line matching $HNMR_section_regex
	    #line.  Then go to OUTSIDE_TABLE
	    if (m/$HNMR_section_regex/){
		$table_state = OUTSIDE_TABLE;
	    }
	    next;
	}elsif ($table_state == OUTSIDE_TABLE){
	    #Read until you find "Table of Peaks", then go to
	    #SEEN_TABLE, reading $HNMR_section_regex will stay in same
	    #state.  At any other # started line, goes back to
	    #NOT_IN_HNMR
	    if     (m/^Table of Peaks$/){
		$table_state = SEEN_TABLE;
	    }elsif (m/$HNMR_section_regex/){
	    }elsif (m/^#/){
		$table_state = NOT_IN_HNMR;
	    }
	    next;
	}elsif ($table_state == SEEN_TABLE){
	    #Check for acceptable header "^No\.([ \t])[A-z.()]" then
	    #extract location of ppm and the separator character.
	    if (m/^No\.([ \t])[A-z.()]/){
		$sep = $1;
		my @fields = split(qr/$sep/);
		$idx_ppm = find_first(qr/\(ppm\)/i,\@fields);
		if($idx_ppm == -1){
		    warn("No ppm field in $file at line $.".
			"Skipping to next file.");
		    next FILE;
		}
		$idx_height = find_first(qr/height/i,\@fields);
		if($idx_height == -1){
		    warn("No height field in $file at line $.".
			"Skipping to next file.");
		    next FILE;
		}
		
		$table_state = SEEN_HEADER;
		next;
	    }else{
		warn("No header for table of peaks in $file.  ".
		     "All files should have a header line right after ".
		     "Table of Peaks.  Skipping to next file.");
		next FILE;
	    }
	}elsif ($table_state == SEEN_HEADER){
	    #Read data until we get to a blank line
	    if (m/^\s*$/){
		last; #We're done with the table if we see a blank line
	    }else{
		#Get the ppm field
		my @fields = split(qr/$sep/);
		my $fp = $fields[$idx_ppm]; 
		my $fh = $fields[$idx_height]; 
		#Trim whitespace from the fields - I don't convert to a
		#number because this way I get exactly the original
		#expression without having any possibility of mangling
		#due to floating point errors
		$fp =~ s/^\s+//;
		$fp =~ s/\s+$//; 
		$fh =~ s/^\s+//;
		$fh =~ s/\s+$//; 
		#Add the fields to the lists
		push @ppms, $fp;
		push @heights, $fh;
		next;
	    }
	}
    }
    #Output the line of ppms for this file
    $file =~ m/HMDB\d\d\d\d\d/;
    my $hmdb_id = $&;
    unshift @ppms, ($hmdb_id,'ppms');
    unshift @heights, ($hmdb_id,'heights');
    print join("\t",@ppms),"\n";
    print join("\t",@heights),"\n";
}
