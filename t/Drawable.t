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

eval { require Prima }
  or plan skip_all => "due to no Prima initialize -- $@";

plan tests => 1517;
require Image::Base::Prima::Drawable;


#------------------------------------------------------------------------------
# VERSION

my $want_version = 2;
is ($Image::Base::Prima::Drawable::VERSION,
    $want_version, 'VERSION variable');
is (Image::Base::Prima::Drawable->VERSION,
    $want_version, 'VERSION class method');

ok (eval { Image::Base::Prima::Drawable->VERSION($want_version); 1 },
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { Image::Base::Prima::Drawable->VERSION($check_version); 1 },
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# xy

{
  my $prima_image = Prima::Image->new (width => 10, height => 10);
  diag "linePattern ", $prima_image->linePattern;
  diag "lineWidth ", $prima_image->lineWidth;

  my $image = Image::Base::Prima::Drawable->new
    (-drawable => $prima_image);
  $prima_image->begin_paint;

  $image->xy (2,2, 'black');
  is ($image->xy (2,2), '#000000');
  $image->xy (2,2, 'white');
  is ($image->xy (2,2), '#FFFFFF');

  require MyTestImageBase;
  MyTestImageBase::dump_image($image);
}

#------------------------------------------------------------------------------
# rectangle

{
  my $prima_image = Prima::Image->new (width => 10, height => 10);

  my $image = Image::Base::Prima::Drawable->new
    (-drawable => $prima_image);
  $prima_image->begin_paint;

  $image->rectangle (0,0, 9,9, 'black', 1);
  is ($image->xy (0,0), '#000000');
  is ($image->xy (9,9), '#000000');
  $image->rectangle (0,0, 9,9, 'white', 1);
  is ($image->xy (0,0), '#FFFFFF');
  is ($image->xy (9,9), '#FFFFFF');

#   require MyTestImageBase;
#   MyTestImageBase::dump_image($image);
}

{
  my $prima_image = Prima::Image->new (width => 10, height => 10);

  my $image = Image::Base::Prima::Drawable->new
    (-drawable => $prima_image);
  $prima_image->begin_paint;

  # unfilled one pixel
  $image->rectangle (2,2, 2,2, 'black');
  is ($image->xy (2,2), '#000000');
  $image->rectangle (2,2, 2,2, 'white');
  is ($image->xy (2,2), '#FFFFFF');

#   require MyTestImageBase;
#   MyTestImageBase::dump_image($image);
}

#------------------------------------------------------------------------------
# ellipse

{
  my $prima_image = Prima::Image->new (width => 10, height => 10);

  my $image = Image::Base::Prima::Drawable->new
    (-drawable => $prima_image);
  $prima_image->begin_paint;

  # unfilled one pixel
  $image->ellipse (2,2, 2,2, 'black');
  is ($image->xy (2,2), '#000000');
  $image->ellipse (2,2, 2,2, 'white');
  is ($image->xy (2,2), '#FFFFFF');

  require MyTestImageBase;
  MyTestImageBase::dump_image($image);
}

#------------------------------------------------------------------------------
# line

{
  my $prima_image = Prima::Image->new (width => 10, height => 10);

  my $image = Image::Base::Prima::Drawable->new
    (-drawable => $prima_image);
  $prima_image->begin_paint;

  $image->line (2,2, 2,2, 'black');
  is ($image->xy (2,2), '#000000');
  $image->line (2,2, 2,2, 'white');
  is ($image->xy (2,2), '#FFFFFF');

#   require MyTestImageBase;
#   MyTestImageBase::dump_image($image);
}
{
  my $prima_image = Prima::Image->new (width => 10, height => 10);

  my $image = Image::Base::Prima::Drawable->new
    (-drawable => $prima_image);
  $prima_image->begin_paint;

  $image->line (0,0, 0,0, 'black');
  is ($image->xy (0,0), '#000000');
  $image->line (0,0, 0,0, 'white');
  is ($image->xy (0,0), '#FFFFFF');

#   require MyTestImageBase;
#   MyTestImageBase::dump_image($image);
}


#------------------------------------------------------------------------------
# check_image

{
  my $prima_image = Prima::Image->new (width => 21, height => 10);
  my $image = Image::Base::Prima::Drawable->new
    (-drawable => $prima_image);
  is ($image->get('-width'),  21);
  is ($image->get('-height'), 10);

  require MyTestImageBase;
  $prima_image->begin_paint;
  MyTestImageBase::check_image ($image);
}

exit 0;
