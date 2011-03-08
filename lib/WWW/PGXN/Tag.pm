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

__END__

=head1 Name

WWW::PGXN::Tag - Tag metadata fetched from PGXN

=head1 Synopsis

  my $pgxn = WWW::PGXN->new( url => 'http://api.pgxn.org/' );
  my $dist = $pgxn->find_tag(name => 'pgTAP');
  $dist->download_to('.');

=head1 Description

This module represents PGXN tag metadata fetched from PGXN>. It is
not intended to be constructed directly, but via the
L<WWW::PGXN/find_tag> method of L<WWW::PGXN>.

=head1 Interface

=begin private

=head2 Constructor

=head3 C<new>

  my $tag = WWW::PGXN::Tag->new($pgxn, $data);

Construct a new WWW::PGXN::Tag object. The first argument must be
an instance of L<WWW::PGXN> that connected to the PGXN server. The second
argument must be the data fetched.

=end private

=head2 Instance Accessors

=head3 C<name>

  my $name = $pgxn->name;
  $pgxn->name($name);

The name of the tag.

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
