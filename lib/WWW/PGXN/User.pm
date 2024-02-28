package WWW::PGXN::User;

use 5.8.1;
use strict;

our $VERSION = v0.13.0;

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
    my ($class, $data) = @_;
    bless $data, $class;
}

sub releases {
    +{ %{ shift->{releases} } }
}

__END__

=head1 Name

WWW::PGXN::User - User metadata fetched from PGXN

=head1 Synopsis

  my $pgxn  = WWW::PGXN->new( url => 'https://api.pgxn.org/' );
  my $user = $pgxn->get_user('theory');
  say $user->name, '<', $user->email, '>';


=head1 Description

This module represents PGXN user metadata fetched from
L<PGXN|https://pgxn.org>. It is not intended to be constructed directly, but
via L<WWW::PGXN/get_user>.

=head1 Interface

=begin private

=head2 Constructor

=head3 C<new>

  my $user = WWW::PGXN::User->new($data);

Construct a new WWW::PGXN::User object. The argument must be the data
fetched.

=end private

=head2 Instance Accessors

=head3 C<nickname>

  my $nickname = $user->nickname;
  $user->nickname($nickname);

The user's nickname (also known as a user name).

=head3 C<name>

  my $name = $user->name;
  $user->name($name);

The full name of the user.

=head3 C<uri>

  my $uri = $user->uri;
  $user->uri($uri);

The URI for the user. May be C<undef> if the user has no URI.

=head3 C<email>

  my $email = $user->email;
  $user->email($email);

The user's email address.

=head3 C<twitter>

  my $twitter = $user->twitter;
  $user->twitter($twitter);

The user's Twitter nickname, if any.

=head3 C<releases>

  my $releases = $user->releases;

Returns a hash reference describing all of the distributions ever released by
the user. The keys of are distribution names and the values are hash
references that may contain the following keys:

=over

=item C<stable>

=item C<testing>

=item C<unstable>

An array reference containing hashes of versions and release dates of all
releases of the distribution with the named release status, ordered from most
to least recent.

=item C<abstract>

A brief description of the distribution. Available only from the PGXN API, not
mirrors.

=back

Here's an example of the C<releases> data structure:

  {
      explanation => {
          abstract => 'Turn an explain plan into a proximity tree',
          stable => [
              { version => '0.2.0', date => '2011-02-21T20:14:56Z' }
          ]
      },
      pair => {
          abstract => 'A key/value pair data type',
          stable => [
              { version => '0.1.1', date => '2010-10-22T16:32:52Z' },
              { version => '0.1.0', date => '2010-10-19T03:59:54Z' }
          ],
          testing => [
              { version => '0.0.1', date => '2010-09-23T14:23:52Z' }
          ]
      },
  }

=head1 See Also

=over

=item * L<WWW::PGXN>

The main class to communicate with a PGXN mirror or API server.

=back

=head1 Support

This module is stored in a public
L<GitHub repository|https://github.com/pgxn/www-pgxn/>.
Feel free to fork and contribute! Please file bug reports via
L<GitHub Issues|https://github.com/pgxn/www-pgxn/issues/>.

=head1 Author

David E. Wheeler <david@justatheory.com>

=head1 Copyright and License

Copyright (c) 2011-2024 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
