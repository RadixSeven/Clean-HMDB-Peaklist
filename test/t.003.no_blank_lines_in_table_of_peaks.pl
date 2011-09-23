#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

########################
# Checks that Table of Peaks is one contiguous unit of the form:
#
# "^Table of Peaks$"
# "^No\.[\t ][A-z()]" (Whether space or tab determines space or tab below)
# "^\d+([ \t]-?\d*\.?\d+){2,}\s*$" (one or more times)
#     (Regex: at least 3 space-separated numeric fields, 
#      first of positive integers only with optional trailing spaces)
# ^\s*$ (one or more times)
# "^#|^Table of"
########################

#List of files to check
my @files = glob("../NMR_Peaklist/HMDB*.txt");

#States of the table-recognizing state-machine.
sub OUTSIDE(){ 1 };
sub SEEN_TABLE(){ 2 };
sub SEEN_HEADER(){ 3 };
sub SEEN_DATA_LINE(){ 4 };
sub SEEN_BLANK_LINE(){ 5 };

#We will perform one test for each file
plan tests=>scalar(@files);

#Read in each file
foreach my $file (@files){
    open(my $fh, "<", $file) or die "Could not open $file";
    my $table_state = OUTSIDE;
    my $sep = ""; #separator - space or tab
    my $sep_in_english = ""; #The way to say the separator character in English
    my $data_line_regex = ""; #The regular expression used for a data line

    #Expected and got are used for the error message.  I leave them
    #alone unless there is an error (thus they will match initially).
    #Then on an error, I set expected to a description of what was
    #expected and got to the actual line.  I abuse the testing system
    #a bit, but the only problem will be if the peaklist files contain
    #lines that exactly match my error message, which I think very
    #unlikely.
    my $expected = "";
    my $got = "";
    while(<$fh>){
	chomp;
	if     ($table_state == OUTSIDE){
	    #Anything is acceptable.  At "Table of Peaks", goes to next state
	    if (m/^Table of Peaks$/){
		$table_state = SEEN_TABLE;
	    }
	    next;
	}elsif ($table_state == SEEN_TABLE){
	    #Must have "^No\.([ \t])[A-z.()]" to be acceptable
	    if (m/^No\.([ \t])[A-z.()]/){
		$sep = $1;
		if($sep eq " "){ 
		    $sep_in_english = "space"; 
		}elsif($sep eq "\t"){ 
		    $sep_in_english = "tab";
		}else{ die "Separator regexp matched something that wasn't ".
			   "a space or a tab."; 
		}
		$data_line_regex = 
		    qr/^\d+($sep-?\d*\.?\d+){2,}(${sep}Gauss\+Lorentz)?\s*$/;
		$table_state = SEEN_HEADER;
		next;
	    }else{
		$expected="A line starting with No. followed by a space or a tab then a letter,\".\" or parenthesis";
		$got=$_;
		last;
	    }
	}elsif ($table_state == SEEN_HEADER){
	    #Must have $data_line_regex to be acceptable
	    if ($_ =~ $data_line_regex){
		$table_state = SEEN_DATA_LINE;
		next;
	    }else{
		$expected="A line with 3+ ${sep_in_english}-separated data ".
		    "fields (the first being an integer)";
		$got=$_;
		last;
	    }
	}elsif ($table_state == SEEN_DATA_LINE){
	    #Can be $data_line_regex or ws line.  WS goes to next
	    #state
	    if ($_ =~ $data_line_regex){
		$table_state = SEEN_DATA_LINE;		
		next;
	    }elsif (m/^\s*$/){
		$table_state = SEEN_BLANK_LINE;
		next;
	    }else{
		$expected="A blank line or a line with 3+ ${sep_in_english}-".
		    "separated data fields (the first being an integer)";
		$got=$_;
		last;
	    }
	}elsif ($table_state == SEEN_BLANK_LINE){
	    #Can be WS or table exit
	    if (m/^\s*$/){
		$table_state = SEEN_BLANK_LINE;
		next;
	    }elsif (m/^Table of Peaks$/){
		$table_state = SEEN_TABLE;
		next;
	    }elsif (m/^#|^Table of/){
		$table_state = OUTSIDE;
		next;
	    }else{
		$expected="A blank line or the start of a new table";
		$got=$_;
		last;
	    }
	}
    }
    is($got, $expected, 
       "All Table of Peaks entries in $file match the expected format.");
}
