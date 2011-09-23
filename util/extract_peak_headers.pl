#!/usr/bin/perl
use strict;
use warnings;

################
# Print the extracted fields of the header line for the first HNMR
# Table of Peaks in an HMDB peaklist file.  
#
# Usage: extract_peak_headers [oneline|multiline] HMDB_peaklist_file.txt

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
sub SEEN_BLANK_LINE(){ 5 };

my $numlines = shift;
unless(($numlines eq 'oneline' || $numlines eq 'multiline') &&
       @ARGV > 0){
    print STDERR 
	"Usage: $0 [oneline|multiline] HMDB_peaklist_file.txt file2 ...\n";
    exit(-1);
}

foreach my $file (@ARGV){
    open(my $fh, "<", $file) or die "Could not open $file";
    my $table_state = NOT_IN_HNMR;
    my $sep = ""; #separator - space or tab
    my $no_hnmr_section = 1; #True until see the first hnmr section
    my $no_table_of_peaks=1; #True until see the first table of peaks
    my $HNMR_section_regex = qr/^.*HNMR.*[Pp]eaklists?:?\s*$/;

    #Expected and got are used for the error message.  I leave them
    #alone unless there is an error (thus they will match initially).
    #Then on an error, I set expected to a description of what was
    #expected and got to the actual line.  
    my $expected = "";
    my $got = "";
    while(<$fh>){
	chomp;
	if    ($table_state == NOT_IN_HNMR){
	    #Anything is acceptable.  A $HNMR_section_regex line goes
	    #to OUTSIDE_TABLE
	    if (m/$HNMR_section_regex/){
		$no_hnmr_section = 0;
		$table_state = OUTSIDE_TABLE;
	    }
	    next;
	}elsif ($table_state == OUTSIDE_TABLE){
	    #Anything is acceptable.  At "Table of Peaks", goes to
	    #next state, at $HNMR_section_regex stays in same state.
	    #At any other # started line, goes back to NOT_IN_HNMR
	    if     (m/^Table of Peaks$/){
		$no_table_of_peaks=0;
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
		if (find_first(qr/^Height$/,\@fields) == -1){
		    my $h_idx = find_first(qr/Height/i,\@fields);
		    if($h_idx != -1){
			print STDERR "$file : Has non-standard height field: ".
			    "'$fields[$h_idx]'\n";
		    }else{
			print STDERR "$file : is missing height field'\n";
		    }
		}
		if($numlines eq 'oneline'){
		    print join("\t", @fields),"\n";
		}else{
		    print join("\n", @fields),"\n";
		}
		last;
	    }else{
		$expected="A line starting with No. followed by a space or a tab then a letter,\".\" or parenthesis";
		$got=$_;
		last;
	    }
	};
    }
    if ($expected ne $got){
	print STDERR "$file : expected '$expected', got 'got'\n";
    }elsif ($no_hnmr_section){
	print STDERR "$file : does not have an HNMR section\n";
    }elsif ($no_table_of_peaks){
	print STDERR "$file : does not have a table of peaks\n";
    }
}

#for my $fn (@ARGV){
#    open(my $fh, '<', $fn) or die $!;
#    #Indices of the various fields
#    my $num_idx=-1;
#    my $ppm_idx = -1;
#    my $height_idx = -1;
#    my $hz_idx = -1;
#    while(<$fh>){
#	#Remove whitespace
#	chomp;
#
#	#Skip rest of file after first blank line
#	last if (m/^\s*$/); 
#
#	#If this is the header line
#	if (m/^No./){ 
#	    #Split the header
#	    my $has_tabs = m/\t/;
#	    my @fields;
#	    if ($has_tabs){
#		@fields = split /\t/;
#	    }else{
#		@fields = split;
#	    }
#	    $num_idx = 0;
#	    $ppm_idx = find_first(qr/ppm/i,\@fields);
#	    $height_idx = find_first(qr/height/i,\@fields);
#	    $hz_idx = find_first(qr/hz/i,\@fields);
#
#	    print "\"$fn\"";
#	    print "\t$fields[$num_idx]" if $num_idx >= 0;
#	    print "\t$fields[$ppm_idx]" if $ppm_idx >= 0;
#	    print "\t$fields[$height_idx]" if $height_idx >= 0;
#	    print "\t$fields[$hz_idx]" if $hz_idx >= 0;
#	    print "\n";
#	}
#    }
#}
