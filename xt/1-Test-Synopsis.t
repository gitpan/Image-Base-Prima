#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

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

use strict;
use warnings;
use Test::More;

use Prima::noX11;

eval 'use Test::Synopsis; 1'
  or plan skip_all => "due to Test::Synopsis not available -- $@";

## no critic (ProhibitCallsToUndeclaredSubs)
all_synopsis_ok();

exit 0;
