package WWW::PGXN;

use 5.8.1;
use strict;

our $VERSION = '0.10';


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
