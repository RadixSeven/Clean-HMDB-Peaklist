#!/usr/bin/perl
use Test::Harness;
if(@ARGV==1){
    $verbose = 1
}else{
    $verbose = 0
}
sub howToExec($$){
    my ( $harness, $test_file ) = @_;
    # Let Perl tests run through the default process.
    return undef if $test_file =~ /[.]pl$/;
}


$h=TAP::Harness->new({verbosity=>$verbose, exec=>\&howToExec}); 
$h->runtests(glob("./t.*.pl"));
