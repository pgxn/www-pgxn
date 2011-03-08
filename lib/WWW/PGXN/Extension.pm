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

__END__

=head1 Name

WWW::PGXN::Extension - Extension metadata fetched from PGXN

=head1 Synopsis

  my $pgxn = WWW::PGXN->new( url => 'http://api.pgxn.org/' );
  my $dist = $pgxn->find_extension(name => 'pgTAP');
  $dist->download_to('.');

=head1 Description

This module represents PGXN extension metadata fetched from PGXN>. It is
not intended to be constructed directly, but via the
L<WWW::PGXN/find_extension> method of L<WWW::PGXN>.

=head1 Interface

=begin private

=head2 Constructor

=head3 C<new>

  my $extension = WWW::PGXN::Extension->new($pgxn, $data);

Construct a new WWW::PGXN::Extension object. The first argument must be an
instance of L<WWW::PGXN> that connected to the PGXN server. The second
argument must be the data fetched.

=end private

=head2 Instance Accessors

=head3 C<name>

  my $name = $pgxn->name;
  $pgxn->name($name);

The name of the extension.

=head3 C<latest>

  my $latest = $pgxn->latest;
  $pgxn->latest($latest);

The status of the latest release. Should be one of:

=over

=item stable

=item testing

=item unstable

=back

=head2 Instance Methods

=head3 C<distribution_for_version>

=head3 C<download_latest_to>

=head3 C<download_stable_to>

=head3 C<download_testing_to>

=head3 C<download_unstable_to>

=head3 C<download_version_to>

=head3 C<info_for_version>

=head3 C<stable_info>

=head3 C<latest_info>

=head3 C<testing_info>

=head3 C<unstable_info>

=head3 C<stable_distribution>

=head3 C<latest_distribution>

=head3 C<testing_distribution>

=head3 C<unstable_distribution>

=head1 See Also

=over

=item * L<WWW::PGXN>

The main class to communicate with a PGXN mirror or API server.

=back

=head1 Support

This module is stored in an open L<GitHub
repository|http://github.com/theory/www-pgxn/>. Feel free to fork and
contribute!

Please file bug reports via L<GitHub
Issues|http://github.com/theory/www-pgxn/issues/> or by sending mail to
L<bug-WWW-PGXN@rt.cpan.org|mailto:bug-WWW-PGXN@rt.cpan.org>.

=head1 Author

David E. Wheeler <david@justatheory.com>

=head1 Copyright and License

Copyright (c) 2011 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
