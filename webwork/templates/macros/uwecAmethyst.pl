# this is silviana amethyst's set of global subroutines and variables for Webwork.
# derived in 2021 from uwecAhrendt.pl

sub _uwecAmethyst_init {}; #don't reload this file


$showHint = 1;

#This problem has a hint that will show after $showHint attempt(s).

sub theresahint {
 my $hintafter = $showHint+1;

my $hintReminder = '';
if ($numOfAttempts<$hintafter && $displayHintsQ == 1){
    $hintReminder = '(This problem has a hint that shows after ' . $hintafter . ' attempts.)';}

$hintReminder;
};





# helpful functions for finding the min or max of an array in perl.

sub array_min{
    my @sorted = num_sort(@_);
    return $sorted[0];
};

sub array_max{
    my @sorted = num_sort(@_);
    return $sorted[-1];
};



1; #required at end of file? - a perl thing
