# Copyright 2010, 2011 Kevin Ryde

# This file is part of Image-Math-Prima.
#
# Image-Math-Prima is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Image-Math-Prima is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Image-Math-Prima.  If not, see <http://www.gnu.org/licenses/>.


package Image::Base::Prima::Image;
use 5.004;
use strict;
use warnings;
use Carp;
use Prima;
use vars '$VERSION', '@ISA';

use Image::Base::Prima::Drawable;
@ISA = ('Image::Base::Prima::Drawable');

$VERSION = 1;

# uncomment this to run the ### lines
#use Smart::Comments '###';

sub new {
  my ($class, %params) = @_;
  ### Prima-Image new: \%params

  # $obj->new(...) means make a copy, with some extra settings
  if (ref $class) {
    if (! defined $params{'-drawable'}) {
      $params{'-drawable'} = $class->{'-drawable'}->dup;
    }
    # inherit everything else, in particular '-file' filename
    %params = (%$class,
               %params);
    $class = ref $class;
  }

  my $filename = delete $params{'-file'};
  if (! exists $params{'-drawable'}) {
    ### create new Prima-Image
    $params{'-drawable'} = Prima::Image->new
      ((defined $params{'-width'}  ? (width =>delete $params{'-width'})  : ()),
       (defined $params{'-height'} ? (height=>delete $params{'-height'}) : ()),
      );
  }

  my $self = bless {}, $class;
  $self->set (%params);

  if (defined $filename) {
    $self->load ($filename);
  }
  return $class->SUPER::new (%params);
}

# my %get_methods = (-codecID  => 'codecID'); # not yet documented
sub _get {
  my ($self, $key) = @_;
  ### Prima-Image _get(): $key
  # if (my $method = $get_methods{$key}) {
  #   return $self->{'-drawable'}->$method;
  # }
  if ($key eq '-file_format') {
    ### extras: $self->{'-drawable'}->{'extras'}
    return _codecid_to_format ($self->{'-drawable'}->{'extras'}->{'codecID'});
  }
  return $self->SUPER::_get($key);
}

sub set {
  my ($self, %params) = @_;
  if (defined (my $format = delete $params{'-file_format'})) {
    my $drawable = $params{'-drawable'} || $self->{'-drawable'};
    $drawable->{'extras'}->{'codecID'} = _format_to_codecid($format);
  }
  $self->SUPER::set(%params);
}

# $codecid is an integer, return string like "PNG" which is the format name
sub _codecid_to_format {
  my ($codecid) = @_;
  if (! defined $codecid) {
    return undef;
  }
  return Prima::Image->codecs->[$codecid]->{'fileShortType'};
}
# $format is a string like "PNG", return integer codecid
# upper/lower case $format is allowed
sub _format_to_codecid {
  my ($format) = @_;
  my $codecs = Prima::Image->codecs;
  foreach my $id (0 .. $#$codecs) {
    if ($codecs->[$id]->{'fileShortType'} =~ /\Q$format/i) {
      return $id;
    }
  }
  croak "No Prima codec for format \"",$format,"\"";
}

sub load {
  my ($self, $filename) = @_;
  ### Prima-Drawable load()
  if (@_ == 1) {
    $filename = $self->get('-file');
  } else {
    $self->set('-file', $filename);
  }
  ### $filename

  # stringize against refs like Path::Class
  $self->{'-drawable'}->load ("$filename", loadExtras => 1)
    or croak "Error loading $filename: ",$@;
  ### extras: $self->{'-drawable'}->{extras}
}

# not yet documented
sub load_fh {
  my ($self, $fh) = @_;
  ### Prima-Drawable load_fh()
  $self->{'-drawable'}->load ($fh, loadExtras => 1)
    or croak $@;
}

sub save {
  my ($self, $filename) = @_;
  ### Prima-Drawable save(): @_
  if (@_ == 2) {
    $self->set('-file', $filename);
  } else {
    $filename = $self->get('-file');
  }
  ### $filename

  # uses $im->{'extras'}->{'codecID'} if set, otherwise filename extension
  # stringize against refs like Path::Class
  $self->{'-drawable'}->save ("$filename")
    or croak "Error saving $filename: ",$@;
}

# not yet documented
sub save_fh {
  my ($self, $fh) = @_;
  # uses $im->{'extras'}->{'codecID'} and croaks if that not set
  $self->{'-drawable'}->save ($fh)
    or croak $@;
}

1;
__END__

=for stopwords Ryde Prima .png PNG JPEG filename

=head1 NAME

Image::Base::Prima::Image -- draw into Prima image

=head1 SYNOPSIS

 use Image::Base::Prima::Image;
 my $image = Image::Base::Prima::Image->new
               (-width => 200, -height => 100);
 $image->line (0,0, 99,99, '#FF00FF');
 $image->rectangle (10,10, 20,15, 'white');

=head1 CLASS HIERARCHY

C<Image::Base::Prima::Image> is a subclass of
C<Image::Base::Prima::Drawable>,

    Image::Base
      Image::Base::Prima::Drawable
        Image::Base::Prima::Image

=head1 DESCRIPTION

C<Image::Base::Prima::Image> extends C<Image::Base> to create and draw into
C<Prima::Image> objects, including file loading and saving.

See C<Image::Base::Prima::Drawable> for the drawing operations.  This
subclass adds image creation and file load/save.  C<begin_paint> /
C<end_paint> bracketing is still necessary.

As of Prima 1.28 the supported file formats for both read and write include
JPEG, PNG, TIFF, GIF, XBM, XPM and BMP.  Prima on X11 draws using the X
server, so an X connection is necessary.  Don't use C<Prima::noX11> or
drawing operations will quietly do nothing.

=head1 FUNCTIONS

=over 4

=item C<$image = Image::Base::Prima::Image-E<gt>new (key=E<gt>value,...)>

Create and return a new image object.  A new C<Prima::Image> object can be
created, usually with a C<-width> and C<-height> (but it also works to set
them later),

    $ibase = Image::Base::Prima::Image->new
               (-width => 200,
                -height => 100);;

Or an existing C<Prima::Image> object can be given

    $ibase = Image::Base::Prima::Image->new
               (-drawable => $prima_image);

=item C<$image-E<gt>load>

=item C<$image-E<gt>load ($filename)>

Load from C<-file>, or with a C<$filename> argument set C<-file> then load.

The Prima C<loadExtras> option is used so as to get the file format
C<codecID> in the underlying image.  

=item C<$image-E<gt>save>

=item C<$image-E<gt>save ($filename)>

Save to C<-file>, or with a C<$filename> argument set C<-file> then save to
that.

As per Prima C<save>, the file format is taken from the underlying
C<$primaimage-E<gt>{'extras'}-E<gt>{'codecID'}> if that's set, otherwise
from the filename extension.  The C<-file_format> attribute below can set
the desired output format.

=back

=head1 ATTRIBUTES

=over

=item C<-file> (string)

For saving Prima takes the file format from the filename extension, for
example ".png".  See L<Prima::image-load>.

=item C<-file_format> (string or C<undef>)

The file format as a string like "PNG" or "JPEG", or C<undef> if unknown or
never set.  Getting or setting C<-file_format> operates on the
C<$primaimage-E<gt>{'extras'}-E<gt>{'codecID'}> field of the underlying
C<Prime::Image>.

After C<load> the C<-file_format> is the format read.  Setting
C<-file_format> can changes the format for a subsequent C<save>.

=back

=head1 SEE ALSO

L<Image::Base>,
L<Prima::Image>,
L<Prima::image-load>,
L<Image::Base::Prima::Drawable>

L<Image::Xpm>,
L<Image::Xbm>,
L<Image::Base::GD>,
L<Image::Base::PNGwriter>
L<Image::Base::Gtk2::Gdk::Pixbuf>

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
