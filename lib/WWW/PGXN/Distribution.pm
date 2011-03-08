package WWW::PGXN::Distribution;

use 5.8.1;
use strict;
use File::Spec;
use Carp;
our $VERSION = '0.10';

BEGIN {
    # XXX Use DateTime for release date?
    # XXX Use Software::License for license?
    # XXX Use SemVer for versions?
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
    )) {
        no strict 'refs';
        *{$attr} = sub {
            $_[0]->_merge_meta unless $_[0]->{version};
            $_[0]->{$attr}
        };
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

# Merging accessor.
sub releases {
    my $self = shift;
    $self->_merge_by_dist unless $self->{releases};
    return $self->{releases};
}

# List accessors.
sub tags         { @{ shift->{tags}             || [] } }
sub maintainers  { @{ shift->{maintainer}       || [] } }
sub versions_for { @{ shift->releases->{+shift} || [] } }

# Instance methods.
sub version_for  { shift->releases->{+shift}[0] }

sub _merge_meta {
    my $self = shift;
    my $rel = $self->{releases};
    my $meta = $self->{_pgxn}->_fetch_json(
        'meta',
        version => $rel->{stable}[0] || $rel->{testing}[0] || $rel->{unstable}[0],
        dist    => $self->{name},
    );
    @{$self}{keys %{ $meta }} = values %{ $meta };
}

sub _merge_by_dist {
    my $self = shift;
    my $by_dist = $self->{_pgxn}->_fetch_json(
        'by-dist', dist => $self->{name}
    );
    @{$self}{keys %{ $by_dist }} = values %{ $by_dist };
}

sub url {
    my $self = shift;
    $self->{_pgxn}->_url_for(
        'dist',
        dist    => $self->name,
        version => $self->version
    );
}

sub download_to {
    my $self = shift;
    $self->{_pgxn}->_download_to(
        shift,
        dist    => $self->name,
        version => $self->version
    );
}

1;

__END__
