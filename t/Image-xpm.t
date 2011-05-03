#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Image-Base-Prima.
#
# Image-Base-Prima is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Image-Base-Prima is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Image-Base-Prima.  If not, see <http://www.gnu.org/licenses/>.

use 5.005;
use strict;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

# uncomment this to run the ### lines
#use Smart::Comments;

use Prima::noX11; # without connecting to the server
use Prima;
{
  my $d = Prima::Image->new;
  my $codecs = $d->codecs;
  diag "codecs: ",join(' ',map {$_->{'fileShortType'}} @$codecs);

  my $have_xpm = 0;
  foreach my $codec (@$codecs) {
    if ($codec->{'fileShortType'} eq 'XPM') {
      $have_xpm = 1;
    }
  }
  if (! $have_xpm) {
    plan skip_all => "due to no XPM codec";
  }
}

plan tests => 12;

require Image::Base::Prima::Image;

my $filename = 'tempfile.xpm';
diag "Tempfile $filename";
unlink $filename;
ok (! -e $filename, "removed any existing $filename");
END {
  if (defined $filename) {
    diag "Remove tempfile $filename";
    unlink $filename
      or diag "Oops, cannot remove $filename: $!";
  }
}

#------------------------------------------------------------------------------
# save() / load()

{
  my $image = Image::Base::Prima::Image->new (-width => 10,
                                              -height => 11,
                                              -hotx => 5,
                                              -hoty => 6);
  is ($image->get('-drawable')->{'extras'}->{'hotSpotX'}, 5);
  is ($image->get('-drawable')->{'extras'}->{'hotSpotY'}, 6);
  $image->save ($filename);
  ok (-e $filename, "save() to $filename");
}
{
  my $image = Image::Base::Prima::Image->new (-file => $filename);
  is ($image->get('-file_format'), 'XPM',
      'load() -file_format');
  is ($image->get('-width'), 10,
      'load() -width');
  is ($image->get('-height'), 11,
      'load() -height');
  is ($image->get('-hotx'), 5,
      'load() -hotx');
  is ($image->get('-hoty'), 6,
      'load() -hoty');
}

#------------------------------------------------------------------------------
# as undef

{
  my $image = Image::Base::Prima::Image->new (-width => 10,
                                              -height => 11);
  $image->set (-hotx => 5,
               -hoty => 6);
  $image->set (-hotx => undef,
               -hoty => undef);
  $image->save ($filename);
  ok (-e $filename, "save() to $filename");
}
{
  my $image = Image::Base::Prima::Image->new (-file => $filename);
  is ($image->get('-hotx'), undef,
      'load() -hotx');
  is ($image->get('-hoty'), undef,
      'load() -hoty');
}

exit 0;
