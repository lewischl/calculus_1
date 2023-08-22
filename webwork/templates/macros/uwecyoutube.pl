#package youtube;

sub _youtube_init {}; #don't reload this file


sub youtubeAmethyst {
  my $video_id = shift // 1;

#iframe('//www.youtube.com/embed/' . $video_id . '?rel=0&amp;modestbranding=1&amp;fs=1', height=>'315', width=>'560', id=>'', name=>'' );

  #my $thehtml = "<iframe src='//www.youtube.com/embed/" . $video_id . "?rel=0&amp;modestbranding=1&amp;fs=1' frameborder='1' height='315' width='560'></iframe>";
  my $thehtml = "<iframe src='//www.youtube.com/embed/" . $video_id . "' width='560' height='315' allowfullscreen='allowfullscreen' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture'></iframe>";

if ($whosTeaching==$amethyst){
  HTML($thehtml, '\fbox{Podcast video.}');}
}



sub youtube {
  my $video_id = shift // 1;

#iframe('//www.youtube.com/embed/' . $video_id . '?rel=0&amp;modestbranding=1&amp;fs=1', height=>'315', width=>'560', id=>'', name=>'' );

  #my $thehtml = "<iframe src='//www.youtube.com/embed/" . $video_id . "?rel=0&amp;modestbranding=1&amp;fs=1' frameborder='1' height='315' width='560'></iframe>";
  my $thehtml = "<iframe src='//www.youtube.com/embed/" . $video_id . "' width='560' height='315' allowfullscreen='allowfullscreen' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture'></iframe>";

  HTML($thehtml, '\fbox{Podcast video.}');
}



1; #required at end of file - a perl thing