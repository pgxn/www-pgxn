package WWW::PGXN;

use 5.8.1;
use strict;
use WWW::PGXN::Distribution;
use WWW::PGXN::Extension;
use WWW::PGXN::Owner;
use WWW::PGXN::Tag;
use HTTP::Tiny;
use URI::Template;
use JSON ();
use Carp;

our $VERSION = '0.10';

sub new {
    my($class, %args) = @_;
    my $self = bless {} => $class;
    for my $key (qw(url proxy)) {
        $self->$key($args{$key}) if exists $args{$key}
    }
    return $self;
}

sub find_distribution {
    my ($self, %p) = @_;
    $p{dist} = delete $p{name} unless exists $p{dist};
    WWW::PGXN::Distribution->new(
        $self,
        $self->_fetch_json((exists $p{version} ? 'meta' : 'by-dist'), %p)
    );
}

sub find_extension {
    my ($self, $ext) = @_;
    WWW::PGXN::Extension->new(
        $self,
        $self->_fetch_json('by-extension', extension => $ext)
    );
}

sub find_owner {
    my ($self, $ext) = @_;
    WWW::PGXN::Owner->new(
        $self,
        $self->_fetch_json('by-owner', owner => $ext)
    );
}

sub find_tag {
    my ($self, $ext) = @_;
    WWW::PGXN::Tag->new(
        $self,
        $self->_fetch_json('by-tag', tag => $ext)
    );
}

sub url {
    my $self = shift;
    return $self->{url} unless @_;
    ($self->{url} = shift) =~ s{/+$}{}g;
    delete $self->{_req};
    $self->{url};
}

sub proxy {
    my $self = shift;
    return $self->{proxy} unless @_;
    $self->{proxy} = shift;
}

sub _uri_templates {
    my $self = shift;
    return $self->{uri_templates} ||= { do {
        my $req = $self->_request;
        my $url = $self->url . '/index.json';
        my $res = $req->get($url);
        croak "Request for $url failed: $res->{status}: $res->{reason}\n"
            unless $res->{success};
        my $tmpl = JSON->new->utf8->decode($res->{content});
        map { $_ => URI::Template->new($tmpl->{$_}) } keys %{ $tmpl };
    }};
}

sub _url_for {
    my ($self, $name) = (shift, shift);
    my $tmpl = $self->_uri_templates->{$name}
        or croak qq{No URI template named "$name"};
    return URI->new($self->url . $tmpl->process(@_));
}

sub _request {
    my $self = shift;
    $self->{_req} ||= $self->url =~ m{^file:} ? WWW::PGXN::FileReq->new : HTTP::Tiny->new(
        agent => __PACKAGE__ . "/$VERSION",
        proxy => $self->proxy,
    );
}

sub _fetch {
    my ($self, $url) = @_;
    my $res = $self->_request->get($url);
    croak "Request for $url failed: $res->{status}: $res->{reason}\n"
        unless $res->{success};
    return $res;
}

sub _fetch_json {
    my $self = shift;
    my $res = $self->_fetch($self->_url_for(@_));
    WWW::PGXN::Distribution->new($self, JSON->new->utf8->decode($res->{content}));
}

sub _download_to {
    my ($self, $file) = (shift, shift);
    my $url = $self->_url_for(dist => @_);
    my $res = $self->_fetch($url);
    if (-e $file) {
        if (-d $file) {
            my @seg = $url->path_segments;
            $file = File::Spec->catfile($file, $seg[-1]);
        } else {
            croak "$file already exists";
        }
    }

    open my $fh, '>:raw', $file or die "Cannot open $file: $!\n";
    print $fh $res->{content};
    close $fh or die "Cannot close $file: $!\n";
    return $self;
}

package
WWW::PGXN::FileReq;

use strict;
use URI::file ();
use File::Spec ();
use URI::Escape ();

sub new {
    bless {} => shift;
}

sub get {
    my $self = shift;
    (my $file = shift) =~ s{^file:}{};
    $file = URI::Escape::uri_unescape(File::Spec->catfile(split m{/}, $file));

    return {
        success => 0,
        status  => 404,
        reason  => 'not found',
        headers => {},
    } unless -e $file;

    open my $fh, '<:raw', $file or return {
        success => 0,
        status  => 500,
        reason  => $!,
        headers => {},
    };

    local $/;
    return {
        success => 1,
        status  => 200,
        reason  => 'OK',
        content => <$fh> || undef,
        headers => {},
    };
}

1;
__END__

=head1 Name

WWW::PGXN - Interface to the PGXN API

=head1 Synopsis

  my $pgxn = WWW::PGXN->new(
      url => 'http://api.pgxn.org/',
  );

  my $dist = $pgxn->distribution('pgTAP');

=head1 Description

This module provide a simple Perl interface over the the L<PGXN
API|http://api.pgxn.org/>.

=head1 Interface

=head2 Constructor

=head3 C<new>

  my $pgxn = WWW::PGXN->new(
      url => 'http://api.pgxn.org/',
  );

Construct a new WWW::PGXN object. The only required attribute is C<url>. The
supported parameters are:

=over

=item C<url>

The base URL for the API server or mirror the client should fetch from.
Required.

=item C<proxy>

URL of a proxy server to use.

=back

=head2 Instance Accessors

=head3 C<url>

  my $url = $pgxn->url;
  $pgxn->url($url);

Get or set the URL for the PGXN mirror or API server.

=head3 C<proxy>

  my $proxy = $pgxn->proxy;
  $pgxn->proxy($proxy);

Get or set the URL for a proxy server to use.

=head2 Instance Methods

=head3 C<find_distribution>

  my $dist = $pgxn->find_distribution(name => $dist_name);

Finds the data for a distribution. Returns a L<WWW::PGXN::Distribution>
object. The supported parameters are:

=over

=item C<name>

The name of the distribution. Required.

=item C<version>

The version of the distribution. Optional.

=back

=head3 C<find_extension>

  my $dist = $pgxn->find_extension($extension_name);

Finds the data for the named extension. Returns a L<WWW::PGXN::Extension>
object.

=head3 C<find_owner>

  my $dist = $pgxn->find_owner($owner_name);

Finds the data for the named owner. Returns a L<WWW::PGXN::Owner> object.

=head3 C<find_tag>

  my $dist = $pgxn->find_tag($tag_name);

Finds the data for the named tag. Returns a L<WWW::PGXN::Tag> object.

=head1 See Also

=over

=item * L<PGXN|http://www.pgxn.org/>

The PostgreSQL Extension Network, the reference implementation of the PGXN
infrastructure.

=item * L<PGXN::API>

Creates and serves a PGXN API implementation from a PGXN mirror.

=item * L<PGXN::Manager|http://github.com/theory/pgxn-manager>

Server for managing a master PGXN mirror and allowing users to upload
distributions to it.

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
