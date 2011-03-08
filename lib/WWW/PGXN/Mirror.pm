package WWW::PGXN::Mirror;

use 5.8.1;
use strict;

our $VERSION = '0.10';

BEGIN {
    for my $attr (qw(
        uri
        frequency
        location
        organization
        timezone
        bandwidth
        src
        rsync
        notes
     )) {
        no strict 'refs';
        *{$attr} = sub { shift->{$attr} };
    }
}

sub new {
    my ($class, $data) = @_;
    bless $data, $class;
}

sub email {
    my ($host, $user) = split /[|]/ => shift->{email};
    return "$user\@$host";
}
