#$guest  = ($effectivePermissionLevel == -5) ;      ####    practice user


 ####  Presume that faculty observers are given TA status (permission 5).

#$observe = ($effectivePermissionLevel >=  5) ;    ####    TA or Professor (permission 10)


#loadMacros( "problemRandomize.pl" ) ;


 ####  Allow a Guest or Observer to always get a new version of problem.

#ProblemRandomize( $when,"Always" ,onlyAfterDue,0, style,"Button" ) if ($guest or $observe) ;


 ####  Allow everybody else (e.g., a student) to get a new version (for more practice)

####  after correct answer(s) to first (scored) version OR after the assignment's due date

#$when = (time >= $main::dueDate ? "Always" : "Correct");

#ProblemRandomize( $when,$when, onlyAfterDue,0, style,"Button" ) if not ($guest or $observe) ;


 ####  Note: those two uses of ProblemRandomize reflect choices which can be made independently,

####  e,g, you could invoke one and zap/comment-out the other.