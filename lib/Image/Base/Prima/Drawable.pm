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


package Image::Base::Prima::Drawable;
use 5.005;
use strict;
use Carp;
use vars '$VERSION', '@ISA';

use Image::Base;
@ISA = ('Image::Base');

$VERSION = 2;

# uncomment this to run the ### lines
#use Smart::Comments '###';

sub new {
  my $class = shift;
  my $self = bless { _set_colour => '' }, $class;
  $self->set (@_);
  return $self;
}

my %get_methods = (-width  => 'width',
                   -height => 'height',
                   # these two not documented yet
                   -depth  => 'get_bpp',
                   -bpp    => 'get_bpp',
                  );
sub _get {
  my ($self, $key) = @_;
  ### Prima-Drawable _get(): $key
  if (my $method = $get_methods{$key}) {
    return $self->{'-drawable'}->$method;
  }
  return $self->SUPER::_get($key);
}

sub set {
  my ($self, %params) = @_;
  my $width  = delete $params{'-width'};
  my $height = delete $params{'-height'};

  %$self = (%$self, %params);

  my $drawable = $self->{'-drawable'};
  if (defined $width) {
    if (defined $height) {
      $drawable->size ($width, $height);
    } else {
      $drawable->width ($width);
    }
  } elsif (defined $height) {
    $drawable->height ($height);
  }
}

sub xy {
  my ($self, $x, $y, $colour) = @_;
  my $drawable = $self->{'-drawable'};
  $y = $drawable->height - 1 - $y;
  if (@_ == 4) {
    #### xy store: $x,$y
    $drawable->pixel ($x,$y, $self->colour_to_pixel($colour));
  } else {
    #### fetch: $x,$y
    return sprintf '#%06X', $drawable->pixel($x,$y);
  }
}

sub line {
  my ($self, $x1,$y1, $x2,$y2, $colour) = @_ ;
  ### Image-Base-Prima-Drawable line(): "$x1,$y1, $x2,$y2"
  my $y_top = $self->{'-drawable'}->height - 1;
  _set_colour($self,$colour)->line ($x1, $y_top-$y1,
                                    $x2, $y_top-$y2);
}

sub rectangle {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;

  # In Prima 1.28 under X, if lineWidth==0 then a one-pixel unfilled
  # rectangle x1==x2 and y1==y2 draws nothing.  This will be just the usual
  # server-dependent behaviour on a zero-width line.  Use bar() for this
  # case so as to be sure of getting pixels drawn whether lineWidth==0 or
  # lineWidth==1.
  #
  my $method = ($fill || ($x1==$x2 && $y1==$y2)
                ? 'bar'
                : 'rectangle');
  my $y_top = $self->{'-drawable'}->height - 1;
  ### Image-Base-Prima-Drawable rectangle(): $method
  _set_colour($self,$colour)->$method ($x1, $y_top - $y1,
                                       $x2, $y_top - $y2);
}
sub ellipse {
  my ($self, $x1, $y1, $x2, $y2, $colour, $fill) = @_;

  # In Prima 1.28 under X, if lineWidth==0 then a one-pixel ellipse x1==x2
  # and y1==y2 draws nothing, the same as for an unfilled rectangle above.
  # Also trouble with diameter==1 when filled draws one pixel short at the
  # right.  Do any width<=2 or height<=2 as a rectangle.
  #
  my $drawable = _set_colour($self,$colour);
  my $y_top = $drawable->height - 1;
  my $dx = $x2-$x1+1; # diameters
  my $dy = $y2-$y1+1;
  if ($dx <= 2 || $dy <= 2) {
    $drawable->bar ($x1, $y_top - $y1,
                    $x2, $y_top - $y2);
  } else {
    # For an even diameter the X,Y centre is rounded down to the next lower
    # integer.  (To be documented in a Prima post 1.28, perhaps.)  For the Y
    # coordinate that rounding down can be applied after flipping $y_top-$y1
    # puts Y=0 at the bottom per Prima coordinates.
    #
    my $method = ($fill ? 'fill_ellipse' : 'ellipse');

    ### Prima ellipse()
    ### $dx
    ### $dy
    ### x centre: $x1 + int(($dx-1)/2)
    ### y centre: ($y_top - $y1) - int($dy/2)
    ### $method

    $drawable->$method ($x1 + int(($dx-1)/2),
                        ($y_top - $y1) - int($dy/2),
                        $dx, $dy);
  }
}

sub _set_colour {
  my ($self, $colour) = @_;
  my $drawable = $self->{'-drawable'};
  if ($colour ne $self->{'_set_colour'}) {
    ### Image-Base-Prima-Drawable _set_colour() change to: $colour
    $self->{'_set_colour'} = $colour;
    $drawable->color ($self->colour_to_pixel ($colour));
  }
  return $drawable;
}

# not documented yet
sub colour_to_pixel {
  my ($self, $colour) = @_;
  ### colour_to_pixel(): $colour

  # Crib: [:xdigit:] new in 5.6, so just 0-9A-F for now
  if ($colour =~ /^#([0-9A-F]{6})$/i) {
    return hex(substr($colour,1));
  }
  if ($colour =~ /^#([0-9A-F]{2})[0-9A-F]{2}([0-9A-F]{2})[0-9A-F]{2}([0-9A-F]{2})[0-9A-F]{2}$/i) {
    return hex($1.$2.$3);
  }

  (my $c = $colour) =~ s/^cl:://;
  if (my $coderef = (cl->can($c) || cl->can(ucfirst($c)))) {
    ### coderef: &$coderef()
    return &$coderef();
  }

  ### $c
  croak "Unrecognised colour: $colour";
}

# is prima_allocate_color() meant to be public?  It's not normally reached
# unless in a paint anyway ...
#
# sub add_colours {
#  ...
# }

1;
__END__

=for stopwords Ryde Prima RGB drawables resizes Image-Base-Prima

=head1 NAME

Image::Base::Prima::Drawable -- draw into Prima window, image, etc

=for test_synopsis my ($d)

=head1 SYNOPSIS

 use Image::Base::Prima::Drawable;
 my $image = Image::Base::Prima::Drawable->new
               (-drawable => $d);
 $image->line (0,0, 99,99, '#FF00FF');
 $image->rectangle (10,10, 20,15, 'white');

=head1 CLASS HIERARCHY

C<Image::Base::Prima::Drawable> is a subclass of C<Image::Base>,

    Image::Base
      Image::Base::Prima::Drawable

=head1 DESCRIPTION

C<Image::Base::Prima::Drawable> extends C<Image::Base> to
draw into a C<Prima::Drawable> drawable, meaning a widget window, off-screen
image, printer, etc.

The native Prima drawing has many more features, but this module can point
some C<Image::Base> style code at a Prima image etc.

Colour names for drawing are "Blue" etc of the Prima colour constants like
C<cl::Blue> (see L<Prima::Drawable/Color space>), plus 2-digit
#RRGGBB or 4-digit #RRRRGGGGBBBB hex.  Internally Prima works in 8-bit RGB
components so 4-digit values are reduced.  Drawables with less than 24-bits
per pixel reduce further.

X,Y coordinates are the usual C<Image::Base> style 0,0 at the top-left
corner.  Prima works from 0,0 as the bottom-left but
C<Image::Base::Prima::Drawable> converts.  There's no support for the Prima
"translate" origin shift.

None of the drawing functions here do a C<$drawable-E<gt>begin_paint>.
That's left to the application, and of course happens automatically in an
C<onPaint> handler call.  The symptom of forgetting is that lines,
rectangles and ellipses don't draw anything.  In the current code C<xy>
might come out because it uses C<$drawable-E<gt>pixel>, but don't rely on
that.

=head1 FUNCTIONS

=over 4

=item C<$image = Image::Base::Prima::Drawable-E<gt>new (key=E<gt>value,...)>

Create and return a new image object.  A C<Prima::Drawable> object must be
given.

    $image = Image::Base::Prima::Drawable->new
               (-drawable => $d);

=item C<$colour = $image-E<gt>xy ($x, $y)>

=item C<$image-E<gt>xy ($x, $y, $colour)>

Get or set the pixel at C<$x>,C<$y>.

Currently colours returned by a get are always 2-digit hex #RRGGBB.  Would
names "Blue" for C<cl::Blue> etc be better for those particular colours?

=back

=head1 ATTRIBUTES

=over

=item C<-drawable> (C<Prima::Drawable> object)

The target drawable.

=item C<-width> (integer)

=item C<-height> (integer)

The width and height of the underlying drawable.  Setting these resizes the
drawable (as per C<$drawable-E<gt>size>, see L<Prima::Drawable/Other
properties>).

=back

=head1 SEE ALSO

L<Image::Base>,
L<Prima::Drawable>,
L<Image::Base::Prima::Image>

L<Image::Base::Gtk2::Gdk::Drawable>,
L<Image::Base::X11::Protocol::Drawable>

=head1 HOME PAGE

http://user42.tuxfamily.org/image-base-prima/index.html

=head1 LICENSE

Image-Base-Prima is Copyright 2010, 2011 Kevin Ryde

Image-Base-Prima is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3, or (at your option) any
later version.

Image-Base-Prima is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along with
Image-Base-Prima.  If not, see <http://www.gnu.org/licenses/>.

=cut
