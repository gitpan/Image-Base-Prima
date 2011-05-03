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

  my $have_png = 0;
  foreach my $codec (@$codecs) {
    if ($codec->{'fileShortType'} eq 'PNG') {
      $have_png = 1;
    }
  }
  if (! $have_png) {
    plan skip_all => "due to no PNG codec";
  }
}

plan tests => 17;

require Image::Base::Prima::Image;

#------------------------------------------------------------------------------
# load() errors

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
  my $eval_ok = 0;
  my $ret = eval {
    my $image = Image::Base::Prima::Image->new
      (-file => $filename);
    $eval_ok = 1;
    $image
  };
  my $err = $@;
  diag "new() err is \"",$err,"\"";
  is ($eval_ok, 0, 'new() error for no file - doesn\'t reach end');
  is ($ret, undef, 'new() error for no file - return undef');
  like ($err, '/^Cannot/', 'new() error for no file - error string "Cannot"');
}
{
  my $eval_ok = 0;
  my $image = Image::Base::Prima::Image->new;
  my $ret = eval {
    $image->load ($filename);
    $eval_ok = 1;
    $image
  };
  my $err = $@;
  diag "load() err is \"",$err,"\"";
  is ($eval_ok, 0, 'load() error for no file - doesn\'t reach end');
  is ($ret, undef, 'load() error for no file - return undef');
  like ($err, '/^Cannot/', 'load() error for no file - error string "Cannot"');
}

#-----------------------------------------------------------------------------
# save() errors

SKIP: {
  eval { Prima->VERSION(1.29); 1 }
    or skip 'due to save() segvs before Prima 1.29, have only'.Prima->VERSION,
      3;
  my $eval_ok = 0;
  my $nosuchdir = 'no/such/directory/foo.png';
  my $image = Image::Base::Prima::Image->new (-width => 1,
                                              -height => 1);
  my $ret = eval {
    $image->save ($nosuchdir);
    $eval_ok = 1;
    $image
  };
  my $err = $@;
  diag "save() err is \"",$err,"\"";
  is ($eval_ok, 0, 'save() error for no dir - doesn\'t reach end');
  is ($ret, undef, 'save() error for no dir - return undef');
  like ($err, '/^Cannot/', 'save() error for no dir - error string "Cannot"');
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
