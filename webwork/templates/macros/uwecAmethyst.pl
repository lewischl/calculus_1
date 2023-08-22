# derived from uwecAhrendt.pl

$instructor_someoneelse = 128737;
$instructor_amethyst = 42;
$instructor_anyone = 187412;


@wantVideosFrom = ($instructor_amethyst, $instructor_anyone); 

sub _uwecAmethyst_init {}; #don't reload this file


$showHint = -1;

#This problem has a hint that will show after $showHint attempt(s).

sub theresahint {
 my $hintafter = $showHint+1;

my $hintReminder = '';
if ($numOfAttempts<$hintafter){
    $hintReminder = '(This problem has a hint that shows after ' . $hintafter . ' attempts.)';}

$hintReminder;
};



sub amethystHint {
my $hintText = shift;

if ($whosTeaching==$amethyst){
$hintText;
}
};




sub array_min{
    my @sorted = num_sort(@_);
    return $sorted[0];
};

sub array_max{
    my @sorted = num_sort(@_);
    return $sorted[-1];
};




