sub _PGuwecTikZutils_init { }

loadMacros('PGtikz.pl');
# 07/26/2022 V1.0.0
# Andrew Swanson
###################################
# This should become a macro starting here 
# If converted to macro .pl file:
# all instances of "\" need to be escaped becoming "\\"
# If converted to macro .pl file, all instances of '~~' need to become '\'
# relevant lines marked with ####!!!!#### before and after! except in TikZ code, where they are marked with %%%%!!!!%%%%
# add a line that says "1;"" tha the end

# two items so far:
# GraphWithTikZ - quickly and easily graphs
# MathObject function (or functions) and MathObject point(s) for display

# TikZComparisonGraph
# A postfilter to display student expression vs correct graph

# quick usage GraphWithTikZ:
# $graph1 = GraphwithTikZ(function => $f);  #single function $f must be a MathObjects function (created with $f=Formula("...") or $f=Compute("..."))
# $graph2 = GraphwithTikZ(function => [$f1,$f2,$f3....],useLegend => 1); #multiple functions with legend
# if graphing multiple functions, each function can take some individual options
# $graph3 = GraphwithTikZ(function => [$f1,[$f2,color => 'green!60!black',thickness => 'thin']], points => Point((1,0)));
# will graph function(s) on a -10:10x-10:10 grid
# Points must be MathObject points, can take options (LabelPoints, Pmark, color, thickness)
# a graph with no function drawn, just points (some with individual options)
# $graph4 = GraphWithTikZ(function=>[],points=>[Point(-5,5),[Point(-3,-5),color=>'red'],[Point(2,2),labelPoints=>0,Pmark=>'o',thickness=>'very thick']]);

# in your display code, use (for example) :
# \{ image($graph, width => 200, tex_size => 1000) \} # if using BEGIN_TEXT...END_TEXT
# [@ image(insertGraph($graph), width => 300, height => 300) @]*  if using BEGIN_PGML...END_PGML


# parameters for the graph as a whole with default values
# xmin=>-10, ymin=>-10, xmax=>10, ymax=>10, xtick=>1, ytick=>1, useLegend=>0 (if useLegend is set to 0 here, changing it for functions has no effect)
# additional_TikZ_axis_parameters=>""  (things that effect the graph as a whole. These are put in the axis environment last, so override...)

# functions are added using the named parameter function in the form function=>$f, or function =>[$f1,$f2,...],
# or to set parameters on an individual function fuction=>[$f1,[$f2,parameter=>...],$f3,...] graphs $f2 differently than $f1 and $f3
# parameters for individual functions (if just one function, can leave for whole graph - if set for whole graph, those become new defaults for individual functions)
# function=>Formula("x"), thickness=>'thick', samples=>51, color=>'blue'
# dmin=>-10, dmax=>10  (the domain of this particular function)
# leftEnd=>'', rightEnd=>'' (what happens at the ends of the function graph if it ends in the grid 
# - other options are 'open', 'closed', and any arrow style known to TikZ including '<', '>', 'Latex', 'o','*'...
# - 'open' and 'closed' attempt to put a circle at the (x,y) of the endpoint where 'o' and '*' put a circle tangent to (x,y)

# to more precisely control sampling or handle functions too complex for pgfplots (eg nested absolute values) use any of these options:
# makeSamples=>0  (if set to 1, makes uniformly spaced samples separated by dx=(xmax-xmin)/(samples-1))
# irregularSamples=>0  (if set to 1, makes samples randomly separated by 1/16 to 31/16 times dx producing on average "samples" samples)
# sampleAt=>[] (a collection of forced x values. If you set sammples=>2, the function will only be sampled at dmin, these values, and dmax)
# sampleAt can be used to force a function to be sampled at a corner.
# smooth =>'smooth' (forces samples to be connected smoothly - if you want sharp corners, use smooth => '')

# Points can be added to a graph by specifying:
# points =>[] (default is no points) Points must be MathObjects points on point can be points=>Point($x,$y)
# for multiple points, use points => [$p1, $p2,...] 
# or include options on the points points =>[$p1,[$p2,Pmark=>...]]
# options for points:
# labelPoints=>1  (Label Points with their (decimal) coordinates - set to zero for no label)
# Pmark=>'*'    (mark point with filled circle. - other options 'o' open circle, 'x', '+', 'star', 'square', 'square*'...)
# Setting Pmark=>'' labels an unmarked point.
# label=>''  Overrides the labeling of coordinates with a TeX expression eg label=>'y=\frac{1}{2}\sqrt(x)'
# points also take thickness and color



# quick usage TikZComparisonGraph
# set up your answer checker as a variable with a postfilter
# $ans1 = Formula("x^2/4");   # the correct answer
# $ans1checker = $ans1->cmp()->withPostFilter(TikZComparisonGraph());  #The basic comparison display is now set up. NOTE: you can chain postfilters
# use $ans1checker in your display code where you would use $ans1->cmp();
# in PGML:
# [: y= :] [_____________________]{$ans1Check}


# any named parameters used by GraphWithTikZ will pass through TikZComparisonGraph, 
# except that the correct answer function and the student answer function will be added to the graph
# There are two additional named parameters for TikZComparisonGraph:
# studentOptions and correctOptions. These take anything that can go with a function in GraphWithTikZ. The defaults are:
# studentOptions=>[color => 'green!60!black',thickness => 'thin'] and a calculated LateX label of the equation y=$exp
# correctOptions=>[color =>'blue', thickness =>'thick'] and the label "correct" in plain text
# TikZComparisonGraph defaults to useLegend=>1 while GraphWithTikZ defaults to useLegend=>0


sub GraphWithTikZ{
   my %args = (
   								#these first options are for the entire graph
	  xmin => -10,				#size of graph
	  xmax => 10,				#size of graph
	  ymin => -10,				#size of graph
	  ymax => 10,				#size of graph
	  xtick => 1,
      ytick => 1,
 	  useLegend => 0,			#determines if entire graph has a legend... it turned on, you can still turn off legend for individual functions
	  additional_TikZ_axis_parameters => "",
	  						    # the next set of options may be set for entire graph or individual functions
      function => Formula("x"),  
      thickness => 'thick',   #individual function option
      samples => 51,           #individual function option
	  color => 'blue',          #individual function option
      dmin => -10,              #domain of function (individual)
	  dmax => 10,               #domain of function (individual)
	  leftEnd => '',			#Options are 'open', 'closed', or any arrow type TikZ understands 'latex' 
	  rightEnd => '',			#ends apply at end of domain or left/right edge of graph to get arrow at top or bottom, calculate where domain meets edge

      							#any of these three will sample the function locally 
      							#rather than sending it to pgfplots to sample
      makeSamples => 0,        #individual function option
      irregularSamples => 0,   #don't make regularly spaced samples
      sampleAt => [],        #force samples at specific locations
      smooth => 'smooth',		#set smooth to '' to force sharp corners (eg for absolute value), when sampling
								#we can also graph individual points
								#in addition, an individual function can take a label
	  points => [],
	  labelPoints => 1,			# label points with their coordinates
	  Pmark => '*',			# * is filled, o is open  or any othermark TikZ knows
      
	  @_
	);
# set up parameters
    my $function = $args{function};
# we may have a single function or reference to an array of functions.
# if it is a single function, change to a reference to an array containing that function
    $function = [$function] unless ref($function) eq 'ARRAY';
    my $thickness = $args{thickness};
    my $samples = $args{samples};
    my $c1 = $args{color};
    my $xmin = $args{xmin};
    my $ymin = $args{ymin};
    my $xmax = $args{xmax};
    my $ymax = $args{ymax};
    my $dmin = $args{dmin};
    my $dmax = $args{dmax};
    my $xtick = $args{xtick};
    my $ytick = $args{ytick};
    my $leftEnd = $args{leftEnd};
    my $rightEnd = $args{rightEnd};
    my $additional = $args{additional_TikZ_parameters};
    my $points = $args{points};
    
#######
# if points are specified it may be a single point,    
    if (ref($points) ne 'ARRAY'){
      $points = [$points]; 
# Test if we have an array reference, but it is not to multiple points
    }elsif(scalar(@$points)>1){
      if((ref($$points[1]) ne 'Value::Point')&&(ref($$points[1]) ne 'ARRAY')) {
        $points = [$points]; #we have a single point with options for it
      }
    }
# Options that apply to general points
    my $labelPoints = $args{labelPoints};
    my $Pmark = $args{Pmark};
# determine if we will have a legend, and if so, set up a legend string
    my $useLegend = $args{useLegend};
####!!!!####
    my $legend = ($useLegend)?"\\legend {":"";
####!!!!####
# set up a string for plotting functions
	my $functiongraph = '';
# draw the function(s)
	foreach my $f (@{$function}) {
      my @options;
      ($f,@options) = @{$f} if ref($f) eq 'ARRAY';
      my %options = (
        thickness => $thickness,
        label => $f->TeX,
        color => $c1,
        dmin => $dmin,
        dmax => $dmax,
        samples => $samples,
        leftEnd => $leftEnd,
        rightEnd => $rightEnd,
        makeSamples => $args{makeSamples},
        sampleAt => $args{sampleAt},
        irregularSamples =>$args{irregularSamples},
        useLegend => $useLegend,
        @options
      );
      $myLegend = $useLegend*$options{useLegend}; #only add a legend entry if both global legend is on and local legend has not been turned off
      my $leftEnd = $options{leftEnd}; my $rightEnd = $options{rightEnd};
      my $arrows = "{";
      $arrows .= $leftEnd if (($leftEnd ne 'open') && ($leftEnd ne 'closed'));
      $arrows .= "-";
      $arrows .= $rightEnd if (($rightEnd ne 'open') && ($rightEnd ne 'closed'));
      $arrows .= "}";
      if (($options{makeSamples})||($options{irregularSamples})||(scalar (@{$options{sampleAt}}))){
        my $perlf = $f->perlFunction;
        my $drawpoints = "";
        my $none = 1;
        my $x = $options{dmin};
        my $y = 0; my $ott = 0;my $utb = 0;my $dy = $ymax-$ymin;
        my $delta = ($options{dmax}-$options{dmin})/($options{samples}-1);
        my $irreg = $args{irregularSamples}?1:0;
        my @at = @{$options{sampleAt}};
        my $next = (scalar @at)?shift @at:$options{dmax}+1;
        my $last = "";
        my $break=0;
        my $is;
        do {
          my $test = eval {$y = &{$perlf}($x)};$is=!length($test);
          if($is){$y="NaN"};
          #if we switch from way above to below, or vice versa, break the line
          if(!defined($y)||(($utb == 1)&&($y>$ymax))||(($ott == 1)&&($y<$ymin))||($y eq 'nope')||($y eq "NaN")){
            if($break==0){$drawpoints .= "($x,NaN)";$break=1;}
          }else{ $break = 0;
          if($y>$ymax+2*$dy){
            $ott = 1;
            $utb = 0
          }elsif($y<$ymin-2*$dy){
            $ott = 0;
            $utb = 1;
          }else{
            $drawpoints .= "($x,$y) ";
            $last = Point($x,$y);
            if ($none){
              my $pxy = Point($x,$y);
              my @p;
              $none = 0;
              if ($leftEnd eq 'open'){
                @p = [$pxy,Pmark => 'o',labelPoints => 0,thickness => $options{thickness},color => $options{color}];
                push (@{$points},@p);
              }elsif ($leftEnd eq 'closed'){
                @p = [$pxy,Pmark => '*',labelPoints => 0,thickness => $options{thickness},color => $options{color}];
                push (@{$points},@p);
              }
            }
          }
          }
          $x += $delta*(1+$irreg*(random(-15,15)/16));
          if($x >= $next){
            $x = $next;
            if(scalar @at){
              $next = shift @at;
            }else{
              $next = $options{dmax}+1;
            }              
          }
        } until ($x>$options{dmax});
        if ($none == 0){
          my $pxy = $last;
          my @p;
          if ($rightEnd eq 'open'){
            @p = [$pxy,Pmark => 'o',labelPoints => 0,thickness => $options{thickness},color => $options{color}];
            push (@{$points},@p);
          }elsif ($rightEnd eq 'closed'){
            @p = [$pxy,Pmark => '*',labelPoints => 0,thickness => $options{thickness},color => $options{color}];
            push (@{$points},@p);
          }
        }    
####!!!!####
        $functiongraph .= "\\addplot [$arrows,$options{thickness},color=$options{color},] plot[$options{smooth}] coordinates {$drawpoints};"; 
####!!!!####        
      }else{
	   my $exp = $f->string;
####!!!!####
	   $exp =~ tr /[]/()/;    #TikZ does not like square brackets
#          $exp =~ s /\*//g ;    #TikZ does not like * for times? or does it
          $exp =~ s /\|([^\|]*)\|/abs\( $1 \)/g;  #TikZ does not like absolute values - assume not nested
       $functiongraph .= "\\addplot [$arrows,$options{thickness},domain=$options{dmin}:$options{dmax},samples=$options{samples},color=$options{color}]{$exp};";             
####!!!!####
     if(($rightEnd eq 'open')||($rightEnd eq 'closed')){
       my $y;
        eval {$y=$f->eval(x => $options{dmax});};
        if(($y ne '')){
         my $pxy = Point($options{dmax},$y);
         if ($rightEnd eq 'open'){
           @p = [$pxy,Pmark => 'o',labelPoints => 0,thickness => $options{thickness},color => $options{color}];
           push (@{$points},@p);
        }elsif ($rightEnd eq 'closed'){
           @p = [$pxy,Pmark => '*',labelPoints => 0,thickness => $options{thickness},color => $options{color}];
           push (@{$points},@p);
         }
         }else{1;}
       }
       if (($leftEnd eq 'open')||($leftEnd eq 'closed')){
         my $y;
        eval {$y=$f->eval(x => $options{dmin});};
        if(($y ne '')){
         $pxy = Point($options{dmin},$y);
	    if ($leftEnd eq 'open'){
		   @p = [$pxy,Pmark => 'o',labelPoints => 0,thickness => $options{thickness},color => $options{color}];
		   push (@{$points},@p);
	     }elsif ($leftEnd eq 'closed'){
           @p = [$pxy,Pmark => '*',labelPoints => 0,thickness => $options{thickness},color => $options{color}];
		   push (@{$points},@p);
	     }
       }else{1;}
       }
     }
        
     my $label = $options{label};
####!!!!####
     $legend .= ($myLegend)?"\$$label\$,":"";
####!!!!####
  }
  $legend .= ($useLegend) ? "}" : "";
  my $pointgraph = "";
  foreach $p (@{$points}){        
    my @options;
    ($p,@options) = @{$p} if ref($p) eq 'ARRAY';
    my %options = (
      labelPoints => $labelPoints,
      Pmark => $Pmark,
      thickness => $thickness,
      color => $c1,
      label=>'',
      @options
    );
    my $text = ($options{labelPoints})?(($options{label})?"$options{label}":$p->TeX):"";
    my $pos = $p->string;
####!!!!####
    $pointgraph .= "\\addplot  
      [$options{thickness},color=$options{color},mark=$options{Pmark}] coordinates {$pos}
    node [label={\$$text\$}]{};";
####!!!!####
  }
  
#start a new graph
  my $graph = createTikZImage();
  $graph->texPackages(['pgfplots']);
  $graph->tikzLibraries('arrows.meta,decorations');
####!!!!#### and watch the \\begin and \\end below
  $graph->addToPreamble("\\pgfplotsset{compat=1.15}");
####!!!!####
  $graph->tex(<< "END_TIKZ");
\\begin {axis}[
  axis lines                = middle,
  xtick distance            = $xtick,
  ytick distance            = $ytick,
  ymin                      = $ymin, ymax = $ymax, xmin = $xmin, xmax = $xmax,
  grid                      = major,
  axis background/.style    = { fill = white },
  legend pos                = outer north east,
  unbounded coords=jump
]
$functiongraph;
$legend;
$pointgraph;
  \\end{axis};
END_TIKZ
  return $graph;
}

# Postfilter that draws comparison graph in student feedback
# no graph drawn if correct
# Usage:
# ANS($ans2->cmp()->withPostFilter(TikZComparisonGraph()));
# can be chained with AnswerHints, for example
sub TikZComparisonGraph{
  return(sub {
    my $ans = shift;
    my $correct = $ans->{correct_value};
    my $student = $ans->{student_value};
    Value::Error("ComparisonGraph can only be used with MathObjects answer checkers") unless ref($correct);
    return $ans unless ref($student);
    if((!$ans->{isPreview})
    &&(($$ans{ans_message} eq '')||($$ans{ans_message} eq "The domain of your function doesn't match that of the correct answer"))
    &&($ans->{score}<1)){
       my @options = @_;
       my %options = (
           useLegend => 1,         #unlike regular graphing, default to using legend
           correctOptions => [],
           studentOptions => [],
           caption => 'Click on the image to enlarge',
           @options
           );
       my $cOpts = $options{correctOptions};
       my %correctOptions = (
         color => 'blue',
         @{$cOpts}
       );
       my %studentOptions = (
         color => 'green!60!black',
         @{$options{studentOptions}}
       );
       my $graph = GraphWithTikZ(
       @options,   #pass everything except functions on
       function => [
         [Formula($correct)
         ,label => "\\mbox{correct}",%correctOptions
         ],
         [$student
         ,label => "y = $ans->{preview_latex_string}",thickness => 'thin',%studentOptions
         ]
       ],useLegend => $options{useLegend});
      my $view = image($graph, width => 300, tex_size => 1000);
      $ans->{student_ans} = $view."<br>$options{caption}<br>";
    }
    return $ans;
  },@_);
}

1;
