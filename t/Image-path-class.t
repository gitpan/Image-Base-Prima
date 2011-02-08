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

eval { require Path::Class }
  or plan skip_all => "due to Path::Class not available -- $@";

plan tests => 6;
use Prima::noX11; # without connecting to the server
require Image::Base::Prima::Image;


my $filename = Path::Class::File->new('tempfile.png');
unlink $filename;
ok (! -e $filename, "remove any existing $filename");
diag "Tempfile ",ref($filename)," stringize $filename";
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
# save() -file_format

{
  my $prima_image = Prima::Image->new (width => 10, height => 10);
  my $image = Image::Base::Prima::Image->new (-drawable => $prima_image,
                                              -file_format => 'jpeg');
  $image->save ($filename);
  ok (-e $filename, "save() -file_format \"jpeg\" to $filename");
}
{
  my $image = Image::Base::Prima::Image->new (-file => $filename);
  is ($image->get('-file_format'), 'JPEG',
      'new(-file) get written -file_format');
}

exit 0;
