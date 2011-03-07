package WWW::PGXN::Distribution;

use 5.8.1;
use strict;

BEGIN {
    # XXX Use DateTime for release date?
    # XXX Use Software::License for license?
    for my $attr (qw(
        abstract
        license
        name
        version
        description
        generated_by
        release_date
        release_status
        sha1
        owner
        releases
    )) {
        no strict 'refs';
        *{$attr} = sub { shift->{$attr} };
    }

    # Hash accessors.
    for my $attr (qw(
        no_index
        prereqs
        provides
        resources
    )) {
        no strict 'refs';
        *{$attr} = sub { +{ %{ shift->{$attr} || {} } } };
    }
}


sub new {
    my ($class, $pgxn, $data) = @_;
    $data->{_pgxn} = $pgxn;
    bless $data, $class;
}

# List accessors.
sub tags         { @{ shift->{tags}             || [] } }
sub maintainers  { @{ shift->{maintainer}       || [] } }
sub versions_for { @{ shift->{releases}{+shift} || [] } }

# Instance mthods.
sub version_for  { shift->{releases}{+shift}[0] }

1;

__END__
