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

__END__

=head1 Name

WWW::PGXN::Owner - Owner metadata fetched from PGXN

=head1 Synopsis

  my $pgxn = WWW::PGXN->new( url => 'http://api.pgxn.org/' );
  my $dist = $pgxn->find_owner(name => 'pgTAP');
  $dist->download_to('.');

=head1 Description

This module represents PGXN owner metadata fetched from PGXN>. It is
not intended to be constructed directly, but via the
L<WWW::PGXN/find_owner> method of L<WWW::PGXN>.

=head1 Interface

=begin private

=head2 Constructor

=head3 C<new>

  my $owner = WWW::PGXN::Owner->new($pgxn, $data);

Construct a new WWW::PGXN::Owner object. The first argument must be
an instance of L<WWW::PGXN> that connected to the PGXN server. The second
argument must be the data fetched.

=end private

=head2 Instance Accessors

=head3 C<nickname>

  my $nickname = $pgxn->nickname;
  $pgxn->nickname($nickname);

The owner's nickname (also known as a user name).

=head3 C<name>

  my $name = $pgxn->name;
  $pgxn->name($name);

The full name of the owner.

=head3 C<uri>

  my $uri = $pgxn->uri;
  $pgxn->uri($uri);

The URI for the owner. May be C<undef> if the owner has no URI.

=head3 C<email>

  my $email = $pgxn->email;
  $pgxn->email($email);

The owner's email address.

=head3 C<twitter>

  my $twitter = $pgxn->twitter;
  $pgxn->twitter($twitter);

The owner's Twitter nickname, if any.

=head3 C<release_info>



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
