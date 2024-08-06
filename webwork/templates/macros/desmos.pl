#package desmos;
# written by silviana amethyst 2023-24

# if you want storage of values from a calculator across submits or reloads, use `sessionStorage`.  
#    see https://developer.mozilla.org/en-US/docs/Web/API/Window/sessionStorage

$desmos_api_key = 'dcb31709b452b1cf9dc26972add0fda6'; # this is the demo key -- REPLACE ME!!!!!!!!!!!!!
$desmos_api_version = '1.9';

sub _desmos_init {}; #don't reload this file

# Functions defined in this file:
# 
# * desmos_enable  -- you must always call this function to enable desmos.
# * desmos_enable_value_in_text  -- makes css styles for displaying values from desmos graphs.  make several to have several styles.
# * desmos_make_div_calculator -- makes a <div> object for a calculator.  you must ensure the name of the div corresponds to the script that generates the calculator later in the problem (probably at the bottom of the code).
# * get_prev_with_default -- for a named answer, gets the previous value if there is one, and thunks to a provided default if there is no previous value.  only works for named answers.
# * desmos_make_div_autoupdated_variable


################################
#  Desmos setup
#
#  In html mode, load the Desmos api script and create the <div> to attach the Desmos graph to.
#  In tex mode, print a message to direct the student to the html version.
#  Desmos API reference: https://www.desmos.com/api/v1.9/docs/index.html



# always call this function to kick off a Desmos problem.
sub desmos_enable{

my $script_url = join('', "https://www.desmos.com/api/v", $desmos_api_version, '/calculator.js?apiKey=', $desmos_api_key);
my $script_text = join('',   '<script src=', '"',  $script_url, '"></script>' );  # the double quotes are needed for the html call.  yep, this is all very silly.

# the empty string here is for joining.  things will be joined by the empty string.
HEADER_TEXT(MODES(
    HTML=>join('', 
    $script_text,
    '<script src=\"https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.js\"></script>',
    '<script src=\"https://cdnjs.cloudflare.com/ajax/libs/d3plus/1.7.3/d3plus.js\"></script>',
    '<script src=\"https://code.jquery.com/jquery-3.1.0.js\"></script>'
    ),
    TeX=>''
));






# this function creates a css style for text or values read from a calculator.
#
# It can take as arguments:
# * `style_name` -- a string, the name of the style.  default `desmoslinkedvalue`.  if you want multiple styles, change this name.  otherwise, its fine to leave this default.
# * `background_color' -- a string, an html color name, which is applied to the rendered text in the problem.  default is 'lightblue'.  color helps the linked value stand out on the page.
# * `padding` -- an integer, the size of the space in the little box around the text.  default: 2.  the unit is pixels.  
# * `border_radius` -- an integer, the rounding radius of the corners of the little box around the text.  default 5.  the unit is pixels.
sub desmos_enable_value_in_text{

my %args = (
    style_name=>'desmoslinkedvalue',
    background_color=>'lightblue',
    padding=>2,
    border_radius=>5,
    @_ # the named arguments from this function will then replace the defaults above
           );

my $n = $args{style_name};
my $c = $args{background_color};
my $p = $args{padding};
my $r = $args{border_radius};

HEADER_TEXT(MODES(
    HTML=>join('',
           '<style>.',$n,'{',
             'border-radius:',$r,'px;',
             'background-color:',$c,';',
             'padding:',$p,'px',
           '}</style>'
          ),
    TeX=>''
));# header_text 
};



# this function makes an html div for use with Desmos.  
#
# It should take as an argument:
# * `id` -- a string, the name of the div.  default `calculator`.  this must match what you call it in the script that constructs the calculator.
# * `wigth' -- width, in pixels. default 800
# * `height` -- the height, in pixels.  default 800
#
#

sub desmos_make_div_calculator{

  my %args = (
    id=>'calculator',
    width=>800,
    height=>800,
    @_
  );


my $identifier = $args{id};
my $w = $args{width};
my $h = $args{height};

MODES(
    HTML=>join('',
           " <div id=\"$identifier\"",
           ' style="',
                    'width: ',$w,'px; ',
            'height: ',$h,'px;',
                '">',
           '</div>'),
    TEX=>'Interactive Desmos graph that can only be correctly viewed online'
);
}; # desmos_make_div

}; # desmos_make_div





###
#
#   functions to help make stateful variables linked to Desmos graph/calculator elements
#
#
#######


# gets the value that was most recently used, and if one 
# doesn't exist, get the provided default value.
sub get_prev_with_default{
my $n = shift;
my $d = shift;

    return ($inputs_ref->{$n})?$inputs_ref->{$n}:$d;
};


# makes an html `div` object so that you can use a 
# java update call in Desmos to update the value of the div 
# for display in the problem.
# 
# arguments to this function:
# 1. `id` -- a string, the name of the div
# 2. `val` -- the initial value for the div to display
# 3. `class` -- the display class of the div for styling.  
#                     this should probably be a style name that you made via the `
#
# note that this does NOT update the value of an answer -- just the div element.  you have to make the callback update the named answer ALSO.
# 
# you must use an `id` for the div, 
# and in the javascript refer to the div by name in the update function.
#
sub desmos_make_div_autoupdated_variable{
    my $id = shift;
    my $val = shift;
    my $class = shift;
    
    return MODES(
    HTML =>join('',
                '<span ',
                ' id="',$id,'"',
                ' class="',$class,'"',
                '>',
                $val,
                '</span>'),
    TeX => 'synchronous online value'
    );
};



# the file must end with this.  ah, perl.
1;
