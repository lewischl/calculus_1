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


# in PG code, this function is expected to take a string and an array reference
#
# like `foo($s, ~~@some_strings)`.  the ~~ is array reference in the PG version of perl.  https://webwork.maa.org/wiki/Basic_Perl_syntax
# silviana amethyst wrote this code, and hated every minute of it.  perl is a nightmare.
#
# but in here, apparently this isn't PG, and \@ is array reference.  this system is absolutely maddening.
#
#  i wrote this function so I could use it in the youtube code to provide a filtering mechanism for which instructors' videos to enable.
#
sub find_string_in_array{
    my $findme   = $_[0]; # should just be a string.  
    my $ra_strings = $_[1]; # expected to be an array reference.  either ~~ or \ before the @ makes an array reference.  either ~~@data or \@data

    my @strings = @$ra_strings; # un-reference, so now we actually have an array

    foreach my $s (@strings){  # loop over the strings in the array.  
        if (index($s,$findme) != -1){  # this is a string comparison.
            return 1;
        }
    }
    return 0;
}




1; #required at end of file? - a perl thing
