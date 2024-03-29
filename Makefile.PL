#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Image-Base-Prima.
#
# Image-Base-Prima is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# Image-Base-Prima is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Image-Base-Prima.  If not, see <http://www.gnu.org/licenses/>.

use 5.005;
use strict;
use ExtUtils::MakeMaker;
use lib 'inc';
use MyMakeMakerExtras;

MyMakeMakerExtras::WriteMakefile
  (NAME         => 'Image-Base-Prima',
   ABSTRACT     => 'Image::Base drawing into Prima windows and images.',
   VERSION_FROM => 'lib/Image/Base/Prima/Drawable.pm',
   AUTHOR       => 'Kevin Ryde <user42@zip.com.au>',
   LICENSE      => 'gpl',
   SIGN         => 1,
   PREREQ_PM    => {
                    # ellipse() $fill done natively, so no need to depend on
                    # Image::Base 1.12 for that
                    'Image::Base' => '1.12',

                    'Prima' => 0,
                    'Prima::noX11' => 0, # used explicitly, so name it
                    # 'Prima::Drawable' => 0, # in core, only Drawable.pod
                    # 'Prima::Image' => 0,    # in core, only Image.pod

                    'Test' => 0,
                   },
   # cf Prima 1.29 is 5.00502
   MIN_PERL_VERSION => '5.005',

   META_MERGE =>
   { recommends =>
     {
      # version 1.29 avoids some segvs in save() to a non-existent
      # directory
      Prima => '1.29',
     },
     resources =>
     { homepage => 'http://user42.tuxfamily.org/image-base-prima/index.html',
     },
     optional_features =>
     { maximum_devel =>
       { description => 'Stuff used variously for development.',
         requires => { 'Smart::Comments'     => 0,
                     },
       },
       maximum_tests =>
       { description => 'Have "make test" do as much as possible.',
         requires => { 'Test::Weaken' => '2.000',
                     },
       },
     },
   });
