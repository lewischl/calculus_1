#package youtube;
# written by silviana amethyst 2021, 2022, 2023, derived from code from Chris Ahrendt.

sub _youtube_init {}; #don't reload this file

# these integers are arbitrary but distinct numbers.  there's probably a bit operation that's much more clever, but nuts to that.  integers in an array with tests for membership using ~~
$instructor_someoneelse = "someone else";
$instructor_amethyst = "silviana amethyst";
$instructor_shull = "Warren Shull";
$instructor_anyone = "any online video source";

$instructor_unset = "unset instructor for video and text filtering";

# remove or 
@wantVideosFrom = ($instructor_amethyst, $instructor_anyone, $instructor_shull);  # 










### 
##
#    functions for embedding Kaltura videos
##
###

sub kalturaAmethyst {
  my $video_id = shift // 1;
  my $start_time = shift // 0; #start at beginning by default (time is in seconds as an integer);

   kalturaFilterBySource($video_id, $start_time, $instructor_amethyst);
}

sub kalturaAnyone {
  my $video_id = shift // 1;
  my $start_time = shift // 0; #start at beginning by default (time is in seconds as an integer);

   kalturaFilterBySource($video_id, $start_time, $instructor_anyone);
}

sub kalturaShull {
  my $video_id = shift // 1;
  my $start_time = shift // 0; #start at beginning by default (time is in seconds as an integer);

   kalturaFilterBySource($video_id, $start_time, $instructor_shull);
}



sub kaltura {
  my $video_id = shift // 1;
  my $start_time = shift // 0; #start at beginning by default (time is in seconds as an integer);

# construct a string with the video embedding
  my $embed_link = "<iframe id='kaltura_player' src='https://cdnapisec.kaltura.com/p/2370711/sp/237071100/embedIframeJs/uiconf_id/42909941/partner_id/2370711?iframeembed=true&playerId=kaltura_player&entry_id=" . $video_id . "&flashvars[streamerType]=auto&amp;" .
"flashvars[mediaProxy.mediaPlayFrom]=" . $start_time . "&amp;" .
"flashvars[localizationCode]=en&amp;flashvars[sideBarContainer.plugin]=true&amp;flashvars[sideBarContainer.position]=left&amp;flashvars[sideBarContainer.clickToClose]=true&amp;flashvars[chapters.plugin]=true&amp;flashvars[chapters.layout]=vertical&amp;flashvars[chapters.thumbnailRotator]=false&amp;flashvars[streamSelector.plugin]=true&amp;flashvars[EmbedPlayer.SpinnerTarget]=videoHolder&amp;flashvars[dualScreen.plugin]=true&amp;flashvars[hotspots.plugin]=1&amp;flashvars[Kaltura.addCrossoriginToIframe]=true&amp;&wid=1_v8ek257i' width='608' height='342' allowfullscreen webkitallowfullscreen mozAllowFullScreen allow='autoplay *; fullscreen *; encrypted-media *' sandbox='allow-downloads allow-forms allow-same-origin allow-scripts allow-top-navigation allow-pointer-lock allow-popups allow-modals allow-orientation-lock allow-popups-to-escape-sandbox allow-presentation allow-top-navigation-by-user-activation' frameborder='0' title='Estimating instantaneous rates of change via limits'></iframe>";

  HTML($embed_link,"MAKE A QR CODE!!!");
}


# kalturaFilterBySource: a generic that allows common code for embedding, and filtering happens a layer outside this function

sub kalturaFilterBySource {
  my $video_id = shift;
my $start_time = shift // 0; #start at beginning by default (time is in seconds as an integer)
my $instructor_id = shift // $instructor_unset; #start at beginning by default (time is in seconds as an integer)


# now we do a filtering operation using the array of allowed instructors
if ($instructor_id ~~ @wantVideosFrom){ # the ~~ means "is contained in"
    kaltura($video_id, $instructor_id);
}
elsif ($instructor_id == $instructor_unset){
    HTML("UNSET INSTRUCTOR ID WHEN EMBEDDING A KALTURA VIDEO.  it's expected to the the third argument to a call to `kalturaFilterBySource`");
}

}









### 
##
#    functions for embedding YouTube videos
##
###



sub youtubeAmethyst {
    my $video_id = shift // 1;
    my $instructor_id = $instructor_amethyst;

    youtubeFilterBySource($video_id, $instructor_id);
}


# takes two arguments.  first, video id.  second, instructor_id
sub youtubeFilterBySource {
    my $video_id = shift // 1;
    my $instructor_id = shift // $instructor_unset;

if ($instructor_id ~~ @wantVideosFrom){ # the ~~ means "is contained in".  
    youtube($video_id);
}

}


# embed a youtube video, with no filtering.  takes one argument
sub youtube {
  my $video_id = shift // 1; # the `1` is the default value.  seems inappropriate, as a video id is required for this function to make any sense.

  # construct two helpful strings.  
      # remember, the . operator below is string concatenation!!!
  my $embed_link = "<iframe src='//www.youtube.com/embed/" . $video_id . "' width='560' height='315' allowfullscreen='allowfullscreen' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture'></iframe>";
  my $inline_link = "https://www.youtube.com/watch?v=" . $video_id;

  # conditional on mode of output (which is NOT controlled here, but is part of "ambient webwork magic")
  HTML($thehtml, '\fbox{Podcast video.}');  HTML($embed_link, '\qrcode[height=1in]{$inline_link}');  # conditionally generate text for electronic or hardcopy display (which is NOT controlled here, but is part of "ambient webwork magic").  note: `HTML` is a terrible name for this command.  
} # re: sub youtube





### 
##
#    functions for text conditionally appearing based on @wantVideosFrom
##
###



# provides conditional appearance of a string of text.  this has a hard time with text that has certain things in it.  (silviana, please be more clear about what breaks this!!)

sub amethystHint {
my $text = shift;
textAmethyst($text);
}


sub textAmethyst {
my $hintText = shift;

textFilterByInstructor($hintText, $instructor_amethyst);
};


sub textShull {
my $hintText = shift;

textFilterByInstructor($hintText, $instructor_shull);
};

sub textFilterByInstructor {
my $hintText = shift;
my $instructor_id = shift // instructor_unset;

if ($instructor_id ~~ @wantVideosFrom){
    $hintText;
}
elsif ($instructor_id == $instructor_unset){
    "UNSET INSTRUCTOR IN textFilterByInstructor.  IT'S THE SECOND ARGUMENT, PLEASE SET IT.  SEE `macros/uwecyoutube.pl` FOR MORE" . $hintText;
}
else{
    ; # this is empty -- this is the code that happens when a course is set up to NOT embed videos from silviana.
}
};






1; #required at end of file - a perl thing