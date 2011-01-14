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


use 5.008;
use strict;
use warnings;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

# Test::Weaken 3 for "contents"
eval "use Test::Weaken 3; 1"
  or plan skip_all => "due to Test::Weaken 3 not available -- $@";

plan tests => 1;

use Prima::noX11; # without connecting to the server
require Image::Base::Prima::Image;

{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub {
         return Image::Base::Prima::Image->new;
       },
     });
  is ($leaks, undef, 'new() defaults');
  MyTestHelpers::test_weaken_show_leaks($leaks);
}

exit 0;
