# the next block of code is from Andy Swanson, for doing answer hints.  

loadMacros(
"answerHints.pl",);


# define some messages to show students.
$rndMsg1 = "The question asks for an exact answer~~nInstead of entering an approximate decimal,~~nuse fractions, square roots, and/or the constant pi to enter your answer.";
$rndMsg2 = "Please provide more digits.";
$decMsg = "Use fractions, roots, and/or the constant pi to enter an exact answer.~~nDon't enter an approximate decimal.";

# stifles the hint in preview mode.
$HintNoPreview = sub {
  my $values = shift;
  $values = [$values] unless ref($values) eq 'ARRAY';
  return sub {
    my ($correct, $student, $ans) = @_;
    return 0 if $ans->{isPreview};
    foreach my $value (@$values) {
      if (Compute($value)->type eq Compute($student)->type){
      return 1 if ($value == $student);}
    }
    return 0;
  }
};



$checkRound = sub {
  my $myTol = shift;
  return sub {
    my ($correct,$student,$ans) = @_;
    return 0 if ($ans->{isPreview});
    $student = Compute($student);
      return 0 if !($correct->typeMatch($student));
      my $test = Compute($correct)->with(tolType => 'relative',  tolerance => $myTol);
      my $result = $test->cmp->evaluate($student);
        return 1 if ($result->{score});
    return 0;
  }
};


# makes sure answer doesn't have a string/strings as a substring.  returns 1 if it does.  0 if it doesn't.
$hasSubString = sub {
  my $strings = shift;
  $strings = [$strings] unless ref($strings) eq 'ARRAY';
  return sub {
    my ($correct,$student,$ans) = @_;
    $test = $ans->{original_student_ans};
    foreach my $string (@$strings) {
        if (index($test,$string)!=-1){
        $ans->{student_ans}=$test; #show the unprocessed answer whether preview or not
        return 0 if ($ans->{isPreview}); #no message for preview
        return 1;
        }
    }
    return 0;
  }
};


# makes sure answer DOES have a string/strings as a substring.  returns 1 if it does.  0 if it doesn't.
$DoesntHaveSubString = sub {
  my $strings = shift;
  return !(hasSubString($strings));
};