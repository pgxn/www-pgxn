package WWW::PGXN::Owner;

use 5.8.1;
use strict;

our $VERSION = '0.10';

BEGIN {
    for my $attr (qw(
        nickname
        name
        email
        uri
        twitter
    )) {
        no strict 'refs';
        *{$attr} = sub { shift->{$attr} };
    }
}

sub new {
    my ($class, $pgxn, $data) = @_;
    $data->{_pgxn} = $pgxn;
    bless $data, $class;
}

sub release_info {
    +{ %{ shift->{releases} } }
}

