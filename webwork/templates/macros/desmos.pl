#package desmos;
# written by silviana amethyst 2023

sub _desmos_init {}; #don't reload this file

$desmos_api_key = 'dcb31709b452b1cf9dc26972add0fda6'; # this is the demo key -- REPLACE ME!!!!!!!!!!!!!

$desmos_api_version = '1.9';



################################
#  Desmos setup
#
#  In html mode, load the Desmos api script and create the <div> to attach the Desmos graph to.
#  In tex mode, print a message to direct the student to the html version.
#  Desmos API reference: https://www.desmos.com/api/v1.8/docs/index.html


sub desmos_enable_construct_new{

my $script_url = join('', "https://www.desmos.com/api/v", $desmos_api_version, '/calculator.js?apiKey=', $desmos_api_key);
my $script_text = join('',   '<script src=', '"',  $script_url, '"></script>' );

TEXT("$script_text");

HEADER_TEXT(MODES(
    HTML=>$script_text,
    TeX=>''
));


};


sub desmos_enable_modify_existing{

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



};


1;
