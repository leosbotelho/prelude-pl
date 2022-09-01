package Arr;

use strict;
use Exporter qw(import);
use Tie::IxHash;
use Scalar::Util qw(reftype);

our @EXPORT = qw(
  OrdHash
  hashKey
  hasArr isArr toArr hasHash isHash
  safeExists
  strIn
  kb_
);

sub OrdHash {
  tie my %arg, 'Tie::IxHash', @_;
  \%arg;
}

sub hashKey { join chr(0x1E), @_ }

sub hasArr { reftype $_[0] eq 'ARRAY' }
sub isArr { ref $_[0] eq 'ARRAY' }

sub toArr { hasArr ($_[0]) ? $_[0] : [$_[0]] }

sub hasHash { reftype $_[0] eq 'HASH' }
sub isHash { ref $_[0] eq 'HASH' }

sub safeExists {
  my $a = shift;
  foreach my $i (@_) {
    return 0 unless (hasHash $a and exists $a->{$i});
    $a = $a->{$i};
  }
  1;
}

sub strIn { my $s = shift; foreach (@_) { return 1 if $_ eq $s; } 0; }

sub kb_ { !$_[1] ? () : @_; }

1;
