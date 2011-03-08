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
    ) || {};
    @{$self}{keys %{ $meta }} = values %{ $meta };
}

sub _merge_by_dist {
    my $self = shift;
    my $by_dist = $self->{_pgxn}->_fetch_json(
        'by-dist', dist => $self->{name}
    ) || {};
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

sub relative_url {
    my $self = shift;
    $self->{_pgxn}->_uri_for(
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

=head1 Name

WWW::PGXN::Distribution - Distribution metadata fetched from PGXN

=head1 Synopsis

  my $pgxn = WWW::PGXN->new( url => 'http://api.pgxn.org/' );
  my $dist = $pgxn->find_distribution(name => 'pgTAP');
  $dist->download_to('.');

=head1 Description

This module represents PGXN distribution metadata fetched from PGXN>. It is
not intended to be constructed directly, but via the
L<WWW::PGXN/find_distribution> method of L<WWW::PGXN>.

=head1 Interface

=begin private

=head2 Constructor

=head3 C<new>

  my $distribution = WWW::PGXN::Distribution->new($distribution, $data);

Construct a new WWW::PGXN::Distribution object. The first argument must be
an instance of L<WWW::PGXN> that connected to the PGXN server. The second
argument must be the data fetched.

=end private

=head2 Instance Accessors

=head3 C<name>

  my $name = $distribution->name;
  $distribution->name($name);

The name of the distribution.

=head3 C<version>

  my $version = $distribution->version;
  $distribution->version($version);

The distribution version distribution. Returned as a string, but may be passed
to L<SemVer> for comparing versions.

  use SemVer;
  my $version = SemVer->new( $distribution->version );

This interface may be modified in the future to return a L<SemVer> object
itself.

=head3 C<abstract>

  my $abstract = $distribution->abstract;
  $distribution->abstract($abstract);

The abstract for the distribution, a very brief description.

=head3 C<license>

  my $license = $distribution->license;
  $distribution->license($license);

The license for the distribution, usually a simple string such as "gpl_3" or
"postgresql". See the L<PGXN Meta spec|http://pgxn.org/meta/spec.html#license>
for details.

=head3 C<owner>

  my $owner = $distribution->owner;
  $distribution->owner($owner);

The nickname of the owner of the distribution. Use the L<WWW::PGXN/find_owner>
method of L<WWW::PGXN> to get more info on the owner:

  my $owner = $pgxn->find_owner( $distribution->owner );
  say "Owned by ", $owner->name, ' <', $owner->email, '>';

=head3 C<description>

  my $description = $distribution->description;
  $distribution->description($description);

The distribution description, longer than the abstract.

=head3 C<generated_by>

  my $generated_by = $distribution->generated_by;
  $distribution->generated_by($generated_by);

The name of the person or application that generated the metadata from which
this distribution object is created.

=head3 C<release_date>

  my $release_date = $distribution->release_date;
  $distribution->release_date($release_date);

The date the distribution was released on PGXN. Represented as a string in
strict L<ISO-8601|http://en.wikipedia.org/wiki/ISO_8601> format and in the UTC
time zone. It may be parsed into a L<DateTime> object like so:

  use DateTime::Format::Strptime;
  my $parser = DateTime::Format::Strptime->new(
      pattern   => '%FT%T',
      time_zone => 'Z'
  );
  my $date = $parser->parse_datetime( '2010-10-29T22:46:45Z' );

This interface may be modified in the future to return a L<DateTime> object
itself.

=head3 C<release_status>

  my $release_status = $distribution->release_status;
  $distribution->release_status($release_status);

The release_status of the distribution. Should be one of:

=over

=item stable

=item testing

=item unstable

=back

=head3 C<sha1>

  my $sha1 = $distribution->sha1;
  $distribution->sha1($sha1);

The SHA-1 digest for the distribution. You can validate the distribution file
like so:

  use Digest::SHA1;
  my $file = $distribution->download_to('.');
  open my $fh, '<:raw', $file or die "Cannot open $file: $!\n";
  my $sha1 = Digest::SHA1->new;
  $sha1->addfile($fh);
  warn $distribution->name . ' ' . $distribution->version
      . ' does not validate against SHA1'
      unless $sha1->hexdigest eq $distribution->sha1;

=head2 Instance Methods

=head3 C<maintainers>

  my @maintainers = $distribution->maintainers;

Returns a list of the maintainers of the module. By the recommendation of the
L<PGXN Meta spec|http://pgxn.org/meta/spec.html#maintainer>, each should be
formatted with a name and email address suitable for on the recipient line of
an email.

=head3 C<no_index>

  my $no_index = $distribution->no_index;

Returns a hash reference describing files and directories that should not be
indexed by search engines or the PGXN infrastructure. The L<PGXN Meta
spec|http://pgxn.org/meta/spec.html#no_index> specifies that the structure of
this hash contain only these keys:

=over

=item C<file>

An array of file names.

=item C<directory>

An array of directory names.

=back

The returned has will be empty if all files may be indexed.

=head3 C<prereqs>

  my $prereqs = $distribution->prereqs;

Returns a hash reference describing the prerequisites of the extension. The
L<PGXN Meta spec|http://pgxn.org/meta/spec.html#prereqs> dictates That the top
level keys of this hash may be any of:

=over

=item C<configure>

=item C<build>

=item C<test>

=item C<runtime>

=item C<develop>

=back

The value for each of these keys must be a hash reference describing the
prerequisites for that part of the extension lifecycle. The keys in this
secondary hash may be any of:

=over

=item C<requires>

=item C<recommends>

=item C<suggests>

=back

Each of these in turn points to another hash reference, the keys of which are
the names of the prerequisite extensions and the values are their minimum
required version numbers. See the
L<Prereq Spec|http://pgxn.org/meta/spec.html#Prereq.Spec> for further
explication of these phases and relationships. Here's an example of what a
typical C<prereqs> hash might look like:

  {
    prereqs => {
      runtime => {
        requires => {
          PostgreSQL => '8.0.0',
          PostGIS    => '1.5.0'
        },
        recommends => {
          PostgreSQL => '8.4.0'
        },
        suggests => {
          semver => 0
        },
      },
      build => {
        requires => {
          prefix => 0
        },
      },
      test => {
        recommends => {
          pgTAP   => 0
        },
      }
    }
  }

=head3 C<provides>

  my $provides = $distribution->provides;

Returns a hash reference describing the resources provided by the
distribution. The keys are the names of the resources (generally extension
names) and their values are hash references describing them. The keys
available in these hashes include:

=over

=item C<file>

The name of the file in which the resource is defined.

=item C<version>

The L<semantic version|SemVer> of the resource.

=item C<abstract>

A brief description of the resource.

=back

Here's an example of the structure for a simple distribution that provides a
single extension:

  {
     pair => {
        abstract => 'A key/value pair data type',
        file     => 'sql/pair.sql',
        version  => '0.1.1'
     }
  }

See the <spec|http://pgxn.org/meta/spec.html#provides> for more information.

=head3 C<releases>

  my $releases = $distribution->releases;

Returns a hash reference providing the status and version of all releases of
the distribution. The hash reference must have one or more of the following
keys:

=over

=item C<stable>

=item C<testing>

=item C<unstable>

=back

The values for each of these keys must be an array reference of the semantic
version numbers with those release statuses, ordered from most to least
recently released. A simple example:

  {
     stable => [ '0.1.1', '0.1.0' ]
  }

=head3 C<resources>

  my $resources = $distribution->resources;

Returns a hash reference describing the resources for the distribution. These
include source code repository information, bug reporting addresses, and the
like. Example:

  {
     bugtracker => {
        web => 'http://github.com/theory/kv-pair/issues/'
     },
     repository => {
        type => 'git',
        url  => 'git://github.com/theory/kv-pair.git',
        web  => 'http://github.com/theory/kv-pair/'
     },
  }

Read the
L<Resources section of the meta spec|http://pgxn.org/meta/spec.html#resources>
for all the details.

=head3 C<tags>

  my @tags = $distribution->tags;

Returns a list of the tags associated with the distribution. Each may be used
to look up further information about the tag via L<WWW::PGXN::Tag> objects
like so:

  for my $tag ( map { $pgxn->find_tag($_) } $distribution->tags ) {
      say $tag->name;
  }

=head3 C<url>

  my $url = $distribution->url;

The absolute URL for the distribution archive file on the mirror or API sever,
such as

  http://api.pgxn.org/dist/pair/pair-0.1.1.pgz

Or, for a file system URL:

  file:/path/to/mirror/dist/pair/pair-0.1.1.pgz

=head3 C<relative_url>

  my $uri = $distribution->relative_uri;

The relative URL of the distribution archive file. That is, just the path
relative to any PGXN mirror root. So rather than the full URL you'd get from
the C<url> method, you just get the path as derived from the distribution URI
template, for example:

  /dist/pair/pair-0.1.1.pgz

=head3 C<download_to>

  my file = $distribution->download_to('.');
  $distribution->download_to('myfile.zip');

Downloads the distribution. Pass the name of the file to save to, or the name
of a directory. If a directory is specified, the file will be written with the
same name as it has on PGXN, such as C<pgTAP-0.24.0.pgz>. Either way, the name
of the file written will be returned. Regardless of the file's name, it will
always be a zip archive.

=head3 C<version_for>

  my $version = $distribution->version_for('testing');

Returns the most recent version for a release status, if any exists. The
supported release statuses are:

=over

=item C<stable>

=item C<testing>

=item C<unstable>

=back

These version numbers can be used to fetch information specific to a version:

  my $test_dist = $pgxn->find_distribution(
      name    => $distribution->name,
      version => $distribution->version_for('testing'),
  );

=head3 C<versions_for>

  my @versions = $distributions->versions_for('stable');

Returns a list of the versions for a particular release status, if any. The
are returned in order from most to least recent.

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
