package Pre;

use strict;
use Exporter qw(import);
use Scalar::Util qw(blessed);

use constant Fs => chr(0x1C);
use constant Gs => chr(0x1D);
use constant Rs => chr(0x1E);
use constant Us => chr(0x1F);

our @EXPORT = qw(
  Fs Gs Rs Us
  $I
  OrdHash
  controlToCaret_
  sighandler
  open_
  print2 print_
  readline_
  close_
  C_Exc
  openApplyClose
  hasNonzeroExitcode
  hasErrLike
  slurp_ slurp
  O_isa
  try__ try_
);

our $I = sub { $_[0] };

# \n, \t allowed
sub controlToCaret_ { $_[0] =~ s/([\c@-\cH\cK-\c_])/'^' . chr(ord($1) + 64)/gre }

sub C_Exc {
  return ($! + 0) ?
    {errno => $! + 0, errstr => $! . ''} : bless ({errno => -1}, 'BlanketExc')
}

sub sighandler { my $f = shift; sub { local ($!, $?, $@); $f->(@_); } }

our $sa_restart = $I;

sub open_ {
  $sa_restart->(sub {
    @_ == 1 ? open ($_[0])               :
    @_ == 2 ? open ($_[0], $_[1])        :
    @_ == 3 ? open ($_[0], $_[1], $_[2]) :
              open ($_[0], $_[1], $_[2], @_[3 .. @_ - 1]);
  })->(@_)
}

sub print2 {
  $sa_restart->(sub {
    (print { shift } @_) ? {that => 1} : {this => C_Exc}
  })->(@_)
}

sub print_ { print2 *STDOUT, @_ }

sub readline_ { $sa_restart->(sub { readline $_[0] })->($_[0]) }

sub close_ { $sa_restart->(sub { close $_[0] })->($_[0]) }

sub openApplyClose {
  my ($f, $mode, @arg) = @_;
  open_ (my $fh, $mode, @arg) or return {this => {open => C_Exc}};
  my $ret = {};
  my $a = $f->($fh);
  $ret->{this}{apply} = $a->{this} if exists $a->{this};
  $ret->{that} = $a->{that} if exists $a->{that};
  unless (close_ ($fh)) {
    $ret->{this}{close} = C_Exc;
  } elsif ($mode eq '|-' or $mode eq '-|') {
    $ret->{exitcode} = $? >> 8;
  }
  $ret
}

sub hasNonzeroExitcode { exists $_[0]->{exitcode} and $_[0]->{exitcode} }

sub hasErrLike { exists $_[0]->{this} or hasNonzeroExitcode $_[0] }

our $slurp_chomp_rs = "\n";

sub slurp_ {
  my $fh = shift;
  my $s = '';
  while (!eof($fh)) {
    my $line = readline_ ($fh);
    return {this => C_Exc, that => $s} if !defined $line;
    $s .= $line;
  }
  if (defined $slurp_chomp_rs and length $slurp_chomp_rs) {
    local $/ = $slurp_chomp_rs;
    chomp $s;
  }
  return {that => $s}
}

sub slurp { openApplyClose \&slurp_, @_ }

sub O_isa { my ($cls, $o) = @_; blessed $o and $o->isa($cls); }

sub try__ { return $@ ? {this => $@} : {that => $_[0]} }

sub try_ { my $f = shift; sub { try__ eval { $f->(@_) } } }

1;
