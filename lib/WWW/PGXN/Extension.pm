package WWW::PGXN::Extension;

use 5.8.1;
use strict;

our $VERSION = '0.10';

BEGIN {
    # Hash accessors.
    for my $k (qw(
        stable
        testing
        unstable
    )) {
        no strict 'refs';
        *{"$k\_info"} = sub { +{ %{ shift->{$k} || {} } } };
    }
}

sub new {
    my ($class, $pgxn, $data) = @_;
    $data->{_pgxn} = $pgxn;
    bless $data, $class;
}

sub name   { shift->{extension} }
sub latest { shift->{latest} }

sub latest_info   {
    my $self = shift;
    return { %{ $self->{$self->{latest}} } };
}

sub stable_distribution   { shift->_dist_for_status('stable')   }
sub testing_distribution  { shift->_dist_for_status('testing')  }
sub unstable_distribution { shift->_dist_for_status('unstable') }

sub latest_distribution   {
    my $self = shift;
    $self->_dist_for_status($self->{latest});
}

sub distribution_for_version {
    my $self = shift;
    my $vdata = $self->info_for_version(shift) or return;
    return $self->{_pgxn}->find_distribution(%{ $vdata->[0] });
}

sub info_for_version {
    my ($self, $version) = @_;
    $self->{versions}{$version};
}

sub _dist_for_status {
    my ($self, $status) = @_;
    my $vdata = $self->{$status} or return;
    return $self->{_pgxn}->find_distribution(%{ $vdata });
}

sub download_stable_to {
    my $self = shift;
    $self->_download_to(shift, $self->{stable});
}

sub download_latest_to {
    my $self = shift;
    $self->_download_to(shift, $self->latest_info);
}

sub download_testing_to {
    my $self = shift;
    $self->_download_to(shift, $self->{testing});
}

sub download_unstable_to {
    my $self = shift;
    $self->_download_to(shift, $self->{unstable});
}

sub download_version_to {
    my ($self, $version, $file) = @_;
    my $info = $self->info_for_version($version) or return;
    $self->_download_to($file, $info->[0]);
}

sub _download_to {
    my ($self, $file, $info) = @_;
    return unless $info;
    $self->{_pgxn}->_download_to(
        $file,
        dist    => $info->{dist},
        version => $info->{version},
    );
}

1;
