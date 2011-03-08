package WWW::PGXN::Tag;

use 5.8.1;
use strict;

our $VERSION = '0.10';

sub new {
    my ($class, $pgxn, $data) = @_;
    $data->{_pgxn} = $pgxn;
    bless $data, $class;
}

sub name { shift->{tag} }

sub release_info {
    +{ %{ shift->{releases} } }
}
