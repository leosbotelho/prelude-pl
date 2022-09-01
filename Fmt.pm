package Fmt;

use strict;
use Exporter qw(import);

our @EXPORT = qw(
  shr_ shr shl
  ltrim rtrim trim trim1 trim1Line
);

sub shr_ { my $i = ' ' x $_[0]; $_[1] =~ s/(?<!\A)^(?=.)/$i/mgr }
sub shr { my $i = ' ' x $_[0]; $i . shr_ (@_) }

sub shl { my $i = ' ' x $_[0]; $_[1] =~ s/^$i//mgr }

our $ltrim = our $rtrim = qr/\s+/;

sub ltrim { shift =~ s/^$ltrim//r }
sub rtrim { shift =~ s/$rtrim$//r }
sub trim  { shift =~ s/^$ltrim|$rtrim$//gr }

sub trim1 { local $ltrim = local $rtrim = qr/\s/; trim @_ }

sub trim1Line {
  local $ltrim = local $rtrim = qr/[^\S\r\n]+/;
  trim @_
}

1;
