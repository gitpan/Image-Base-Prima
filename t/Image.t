#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Image-Math-Prima.
#
# Image-Math-Prima is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Image-Math-Prima is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Image-Math-Prima.  If not, see <http://www.gnu.org/licenses/>.

use 5.004;
use strict;
use warnings;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

# uncomment this to run the ### lines
#use Smart::Comments;

plan tests => 23;
use Prima::noX11; # without connecting to the server
require Image::Base::Prima::Image;


#------------------------------------------------------------------------------
# VERSION

my $want_version = 1;
is ($Image::Base::Prima::Image::VERSION,
    $want_version, 'VERSION variable');
is (Image::Base::Prima::Image->VERSION,
    $want_version, 'VERSION class method');

ok (eval { Image::Base::Prima::Image->VERSION($want_version); 1 },
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { Image::Base::Prima::Image->VERSION($check_version); 1 },
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# new() width/height

{
  my $image = Image::Base::Prima::Image->new;
  isa_ok ($image, 'Image::Base::Prima::Image');
  isa_ok ($image->get('-drawable'), 'Prima::Image');
}
{
  my $image = Image::Base::Prima::Image->new
    (-width => 123);
  is ($image->get('-width'), 123);
}
{
  my $image = Image::Base::Prima::Image->new
    (-height => 234);
  is ($image->get('-height'), 234);
}
{
  my $image = Image::Base::Prima::Image->new
    (-width => 345,
     -height => 456);
  is ($image->get('-width'), 345);
  is ($image->get('-height'), 456);
}

#------------------------------------------------------------------------------
# new() clone image

{
  my $i1 = Image::Base::Prima::Image->new (-width => 11, -height => 22);
  my $i2 = $i1->new;
  $i2->set(-width => 33, -height => 44);

  is ($i1->get('-width'), 11);
  is ($i1->get('-height'), 22);
  is ($i2->get('-width'), 33);
  is ($i2->get('-height'), 44);
  isnt ($i1->get('-drawable'), $i2->get('-drawable'));
}

#------------------------------------------------------------------------------
# save() / load()

my $filename = 'tempfile.png';
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

{
  my $prima_image = Prima::Image->new (width => 10, height => 10);
  my $image = Image::Base::Prima::Image->new (-drawable => $prima_image);
  $image->save ($filename);
  ok (-e $filename, "save() to $filename");
}
{
  my $image = Image::Base::Prima::Image->new (-file => $filename);
  is ($image->get('-file_format'), 'PNG',
     'load() with new(-file)');
}
{
  my $image = Image::Base::Prima::Image->new;
  $image->load ($filename);
  is ($image->get('-file_format'), 'PNG',
      'load() method');
}

#------------------------------------------------------------------------------
# save -file_format

{
  my $prima_image = Prima::Image->new (width => 10, height => 10);
  my $image = Image::Base::Prima::Image->new (-drawable => $prima_image,
                                              -file_format => 'jpeg');
  $image->save ($filename);
  ok (-e $filename);
}
{
  my $image = Image::Base::Prima::Image->new (-file => $filename);
  is ($image->get('-file_format'), 'JPEG',
      'written to explicit -file_format not per extension');
}

#------------------------------------------------------------------------------
# save_fh()

{
  my $image = Image::Base::Prima::Image->new (-width => 1, -height => 1,
                                              -file_format => 'png');
  unlink $filename;
  open OUT, "> $filename" or die;
  $image->save_fh (\*OUT);
  close OUT or die;
  ok (-s $filename, 'save_fh() not empty');
}

#------------------------------------------------------------------------------
# load_fh()

{
  my $image = Image::Base::Prima::Image->new;
  open IN, "< $filename" or die;
  $image->load_fh (\*IN);
  close IN or die;
  is ($image->get('-file_format'), 'PNG',
      'load_fh() -file_format');
}

exit 0;
