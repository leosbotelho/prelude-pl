package Pre::Candy;

use strict;
use Exporter qw(import);
use Pre qw(openApplyClose print2 slurp);
use Data::Dumper;

our @EXPORT = qw(
  die_
  slurp_ slurp
  writeFile
);

sub die_ {
  local $Data::Dumper::Terse = 1;
  local $Data::Dumper::Indent = 1;
  die Dumper @_
}

sub slurp_ {
  my $ret = Pre::slurp (@_);
  die_ 'slurp', @_, $ret->{this} if exists $ret->{this};
  $ret->{that}
}

sub slurp { slurp_ '<', @_ }

sub writeFile {
  my $mode = @_ == 2 ? '>' : shift;
  my ($filepath, $s) = @_;
  my $ret = openApplyClose sub { print2 $_[0], $s }, $mode, $filepath;
  die_ 'writeFile', $_[0], $ret->{this} if exists $ret->{this};
  $ret->{that}
}

1;
