# derived from uwecAhrendt.pl

$someoneelse = 128737;
$amethyst = 42;

$whosTeaching = $amethyst;

sub _uwecAmethyst_init {}; #don't reload this file


$showHint = 1;

#This problem has a hint that will show after $showHint attempt(s).

sub theresahint {
 my $hintafter = $showHint+1;

my $logReminder = '';
if ($numOfAttempts<$hintafter and $problemSeed%4==0){
    $logReminder = 'And remember to log your lessons!';}

my $hintReminder = '';
if ($numOfAttempts<$hintafter){
    $hintReminder = 'This problem has a hint that shows after ' . $hintafter . ' attempts. ';}

$hintReminder . $logReminder;
};



sub amethystHint {
my $hintText = shift;

if ($whosTeaching==$amethyst){
$hintText;
}
};