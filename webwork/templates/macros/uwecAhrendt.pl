#package uwecAhrendt;

loadMacros(
  "PGstandard.pl",
  "PGbasicmacros.pl",
  "PGunion.pl",
  "MathObjects.pl",
);


sub _uwecAhrendt_init {}; #don't reload this file

$TEXT_ENLARGE = "$BITALIC (Click the image for a larger version.) $EITALIC";
$TEXT_CONSTANT_c = "(Use $BBOLD c$EBOLD to denote an arbitrary constant.)";




$BDEFN = HTML('<blockquote style="border: 2px solid #666; padding: 10px; margin: 10px 100px 10px 100px; background-color: #ccc;"><b>Definition:</b>','Definition:');
$EDEFN = HTML('</blockquote>', '');


$BTHRM = HTML('<blockquote style="border: 2px solid #666; padding: 10px; margin: 10px 100px 10px 100px; background-color: #ccc;">','');
$ETHRM = HTML('</blockquote>', '');

$EX = HTML('<span style="border: 2px solid #666; padding: 2px; background-color: #ccc; font-weight:bold;">Example:</span>','Example:');

$SOLN = HTML('<span style="border: 2px solid #666; padding: 2px; background-color: #ccc; font-weight:bold;">Solution:</span>','Soluton:');

#args: textbook_abbrev, section, problem
sub textbook {
  my $textbook = shift // 1;
  my $section = shift //1;
  my $prob = shift // 1;

'Textbook: \(\S' .  $section . ', ' . $prob . '\) $BR$HR';
}

#these use the HTML() command which is provided by PGunion.pl I believe
$BH2 = HTML('<CENTER><H2>','\begin{center}\textbf{');
$EH2 = HTML('</H2></CENTER>','}\end{center}');


1; #required at end of file - a perl thing
