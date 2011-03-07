package WWW::PGXN::Distribution;

use 5.8.1;
use strict;

for my $attr (qw(name releases)) {
    no strict 'refs';
    *{$attr} = sub { shift->{$attr} };
}

sub new {
    my ($class, $pgxn, $data) = @_;
    $data->{_pgxn} = $pgxn;
    bless $data, $class;
}

sub stable_version {
    shift->{releases}{stable}[0];
}

sub testing_version {
    shift->{releases}{testing}[0];
}

sub unstable_version {
    shift->{releases}{unstable}[0];
}

1;

__END__
