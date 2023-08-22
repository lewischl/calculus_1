# this file provides some helper CSS for styling content and placing answer boxes.  it should be loaded AFTER the `TEXT(beginproblem());` line in the problem file.
# 
# silviana amethyst, 2023, with snippets from other authors as credited below by referencing the url's i used

# I grabbed hex color codes from https://htmlcolorcodes.com/
# i would prefer to name the colors.  that's a todo.

# provides a style for the main statement of a problem.  
# the purpose of this is to highlight it against instruction or dialogue surrounding the problem.

# example use (in PGML -- I'm trying to get away from the old style where possible):
# 
# [@ openDiv({ "class" => "trainingProblemStatement" }) @]*
# A ball is thrown straight up into the air with an initial velocity of 
# [` [$v0] `] ft/s, its height in feet after [` t `] seconds is given by the function
# [``` y(t) = [$y] ```]
# [@ closeDiv() @]*

$standardtablecss='border:solid 1px;     border-collapse: separate; border-radius: 5px; padding: 10px; border-spacing: 10px 0px';

TEXT( MODES(
  HTML=>"
    <style>
      .trainingProblemStatement {
        border: 2px solid #fdebd0;
        border-radius: 5px;
        background-color: #fef9e7 ;
        border-style: inset;
        padding: 5px;
        width: 75%;
        margin: auto;
      }
    </style>
  ",
  TeX=>""
));


TEXT( MODES(
  HTML=>"
    <style>
      .warning {
        border: 2px solid #ff372d;
        border-radius: 5px;
        background-color: #ffce90 ;
        border-style: inset;
        padding: 5px;
        width: 75%;
        margin: auto;
      }
    </style>
  ",
  TeX=>""
));

# an in-problem hint -- one that's not inside BEGIN_HINT, and thus always visible.  
TEXT( MODES(
  HTML=>"
    <style>
      .inProblemHint {
        border: 2px solid #d6eaf8;
        border-radius: 5px;
        background-color: #ebf5fb ;
        border-style: inset;
        padding: 5px;
        width: 75%;
      }
    </style>
  ",
  TeX=>""
));


# this one is for the smaller prompts in a problem, 
# again to help them stand out against additional instruction or dialogue
TEXT( MODES(
  HTML=>"
    <style>
      .promptOrInstruction {
        border: 2px solid #7f6707;
        border-radius: 5px;
        background-color: #fff4e6;
        border-style: inset;
        padding: 5px;
        width: 75%;
      }
    </style>
  ",
  TeX=>""
));

# make that mathy stuff stand out!  

# example use:
#
# [@ openDiv({ "class" => "importantFormula" }) @]*
# [```
# \textnormal{AROC} = \frac{y(t_0 + \Delta t) - y(t_0)}{\Delta t}
# ```]
# [@ closeDiv() @]*

TEXT( MODES(
  HTML=>"
    <style>
      .importantFormula {
        border: 2px solid #d7bde2;
        border-radius: 5px;
        background-color: #ebdef0;
        border-style: inset;
        padding: 5px;
        width: auto;
        margin: auto;
        width: 75%;
      }
    </style>
  ",
  TeX=>""
));




# a statement of purpose, for practicing transparent design.  
TEXT( MODES(
  HTML=>"
    <style>
      .problemPurpose {
        border: 2px solid #eaeded ;
        border-radius: 5px;
        background-color: #f4f6f6 ;
        border-style: inset;
        padding: 5px;
        width: 75%;
      }
    </style>
  ",
  TeX=>""
));



# the next block enables a css div style for putting answer boxes as bounds of an integral.  
# the horizontal alignments are achieved via the `top` and `left` parameters in the `gridForPairOfIntegrationBounds`

# copy-pasted from
# https://webwork.maa.org/moodle/mod/forum/discuss.php?d=4767

# Code to format the answer boxes for integration limits
# The settings for specific answer boxes are for the regular
# non-MathQuill input boxes, and much the lower bound down a bit
# and set a smaller font / input box height. Since the input boxes
# are not inside the grid layout, much of the code to relocate
# the boxes and control their width is not needed any more.
# The class based formatting handles the grid layout, and putting
# the series of DIVs all on one line.

TEXT( MODES(
  HTML=>"
    <style>
      .lowerIntegrationBoundOfPair input[type=text].codeshard {
        padding:0px;
        margin-top: 5px;
        font-size:8pt;
        height:18px !important;
      }
      .upperIntegrationBoundOfPair input[type=text].codeshard {
        padding:0px;
        font-size:8pt;
        height:18px !important;
      }
      
      .divOnLineWithIntegrationLimits {
        display:inline-block;
        position: relative;
        left: -6px;
      }
      .gridForPairOfIntegrationBounds {
        display:inline-grid;
        position: relative;
        top: -17px;
        left: -14px;
        grid-gap: 6px;
        text-align: left;
      }
      .lowerIntegrationBoundOfPair {
        grid-column: 1; grid-row: 2;
      }
      .upperIntegrationBoundOfPair {
        grid-column: 1; grid-row: 1;
        padding-left: 10px;
      }
         </style>",
    TeX=>""
));





# this next block provides a bit of styling for answer boxes in a fraction, numerator or denominator, and the line between them is flexibly sized.
# written by silviana amethyst
# 
# notably:
#    * the vertical sizing is achieved via `grid-template-rows` having value `auto`.
#    * the `line` definition is the line between numerator and denominator

# some websites I used to help write this code:
#
# to help make numerator and denominator not be very far apart vertically
# https://stackoverflow.com/questions/41916722/how-do-i-specify-row-heights-in-css-grid-layout 
#
# to put flexibly sized line between numerator and denominator for the division symbol
# https://stackoverflow.com/questions/50769251/border-after-each-row-in-css-grid


 TEXT( MODES(
  HTML=>"
    <style>
      .ansInDenom input[type=text].codeshard {
        padding:0px;
        font-size:16pt;
        height:18px !important;
      }
      .ansInNumer input[type=text].codeshard {
        padding:0px;
        font-size:16pt;
        height:18px !important;
      }

      .gridForFrac {
        display:inline-grid;
        position: relative;
        top: -18px;
        left: 0px;
        grid-gap: 1px;
        text-align: center;
        grid-template-rows: auto auto auto;  
      }

      .inNumer {
        grid-column: 1; grid-row: 1;
      }
      .inDenom {
        grid-column: 1; grid-row: 2;
      }

.line {
  grid-column: 1 / -1;
  height: 1px;
  background: black;
}

   </style>",
    TeX=>""
));




# you have to open a div and close a div around things before and after this to avoid newlines.
sub ans_fraction{

if ($displayMode eq 'TeX') {
   $frac_text = join("", (
      '\( \frac{', ans_rule(14), '}{', ans_rule(14), '} \)' ));
  } else {
   $frac_text = join("", (

        openDiv( { "class" => "gridForFrac" } ),
          openDiv( { "class" => "ansInNumer" }),
              ans_rule(),
          closeDiv(),
          
          openDiv( { "class" => "line" }),closeDiv(), # the horizontal line for division is CSS-generated so it resizes!
          
          openDiv( { "class" => "ansInDenom" }),
              ans_rule(),
          closeDiv(),
        closeDiv(),
   ) # the list of things we're joining
   ); # the join function call
}

}  # ans_fraction



# you have to open a div and close a div around things before and after this to avoid newlines.
# i have found hspace{-4mm} brings the math after the answer boxes horizontally better aligned.
sub integral_ans_both_bounds{

Context()->texStrings;
if ($displayMode eq 'TeX') {
   return join("", (
      '\( \displaystyle \int_{ ',
      ans_rule(5),
      ' }^{ ',
      ans_rule(5),
      '}'));
  } else {
   return join("", (
        openDiv( { "class" => "divOnLineWithIntegrationLimits" } ),
          '\( \displaystyle \int \)',
        closeDiv(),

        openDiv( {  "class" => "gridForPairOfIntegrationBounds" } ),
          openDiv( {  "class" => "lowerIntegrationBoundOfPair" } ),
            ans_rule(5),
          closeDiv(),
          openDiv( {  "class" => "upperIntegrationBoundOfPair" } ),
            ans_rule(5),
          closeDiv(),
        closeDiv(),
   ) );
}
Context()->normalStrings;

} # subroutine


