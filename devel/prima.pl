#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Image-Base-Prima.
#
# Image-Base-Prima is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Image-Base-Prima is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Image-Base-Prima.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
use strict;
use warnings;
# use blib "$ENV{HOME}/perl/prima/Prima-1.29/blib";
use lib "$ENV{HOME}/perl/prima/Prima-1.29/inst/local/lib/perl/5.10.1/";
# use Prima::noX11;
use Prima;

use Smart::Comments;

{
  my $d = Prima::Image->create (width => 1,
                                height => 1,
                               );
  $d->save ('/tmp/nosuchdir/z.png');
  exit 0;
}

{
  my $d = Prima::Image->create (width => 1,
                                height => 1,
                                type => im::bpp32(),
                               );
  my $green = cl::Green;
  ### green: $green;
  $d->begin_paint;
  $d->color (cl::Black());
  $d->pixel(0,0, cl::Green);
  ### pixel: $d->pixel(0,0)
  $d->end_paint;
  exit 0;
}

{
  printf "white %X\n", cl::White();
  my $coderef = cl->can('White');
  printf "white coderef %s  %X\n", $coderef, &$coderef();

  require Image::Base::Prima::Drawable;
  my $d = Prima::Image->create (width => 100,
                                height => 100,
                                type => im::bpp8(),
                                # type => im::RGB(),
                               );
  # $d-> palette([0,255,0],[255,255,255], [0xFF,0x00,0xFF], [0x00,0xFF,0x00]);
  # $d-> palette([0,255,0, 255,255,255, 0xFF,0x00,0xFF, 0x00,0xFF,0x00]);
  # $d-> palette(0x000000, 0xFF00FF, 0xFFFFFF, 0x00FF00);
  ### palette: $d-> palette

  ### bpp: $d->get_bpp

  my $image = Image::Base::Prima::Drawable->new
    (-drawable => $d);
  print "width ", $image->get('-width'), "\n";
  $image->set('-width',20);
  $image->set('-height',10);
  print "width ", $image->get('-width'), "\n";

  $d->begin_paint;
  $d->color (cl::Black());
  $d->bar (0,0, 20,10);
  # $image->ellipse(1,1, 18,8, 'white');
  $image->ellipse(1,1, 5,3, 'white', 1);
  # $image->xy(6,4, 'white');
   $image->rectangle(0,0,10,10, 'green');

  # $image->xy(0,0, '#00FF00');
  # $image->xy(1,1, '#FFFF0000FFFF');
  # print "xy ", $image->xy(0,0), "\n";
  # say $d->pixel(0,0);

  $d->end_paint;
  $d-> save('/tmp/foo.gif') or die "Error saving:$@\n";
  system "xzgv -z /tmp/foo.gif";
  exit 0;
}



{
  my $image = Image::Base::Prima::Image->new (-width => 20, -height => 10);
  $image->rectangle (1,1, 8,8, 'white');
  exit 0;
}





{
  use Prima;
  use Prima::Const;

  my $d = Prima::Image->create (width => 5, height => 3);
  $d->begin_paint;
  $d->lineWidth(1);

  $d->color (cl::Black);
  $d->bar (0,0, 50,50);

  $d->color (cl::White);
  $d->fill_ellipse (2,1, 5,3);

  $d->end_paint;
  $d-> save('/tmp/foo.gif') or die "Error saving:$@\n";
  system "xzgv -z /tmp/foo.gif";
  exit 0;
}





{
  # available cL:: colour names
  require Prima;
  my @array;
  foreach my $name (keys %cl::) {
    if ($name eq 'AUTOLOAD' || $name eq 'constant') {
      print "$name\n";
      next;
    }
    my $var = "cl::$name";
    my $value = do { no strict 'refs'; &$var(); };
    push @array, [$name, $value];
  }
  foreach my $elem (sort {$a->[1] <=> $b->[1]} @array) {
    printf "%8s %s\n", sprintf('%06X',$elem->[1]), $elem->[0];
  }
  exit 0;
}
