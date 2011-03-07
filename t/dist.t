#!/usr/bin/env perl -w

use strict;
use warnings;
use Test::More tests => 10;
#use Test::More 'no_plan';
use WWW::PGXN;

# Set up the WWW::PGXN object.
my $pgxn = new_ok 'WWW::PGXN', [ url => 'file:t/mirror' ];

##############################################################################
# Fetch distribution data.
ok my $dist = $pgxn->find_distribution(name => 'pair'),
    'Find distribution "pair"';
isa_ok $dist, 'WWW::PGXN::Distribution', 'It';
can_ok $dist => qw(
    name
    releases
    stable_version
    testing_version
    unstable_version
);
is $dist->{_pgxn}, $pgxn, 'It should contain the WWW::PGXN object';

# Examine the distribution data.
is $dist->name, 'pair', 'Distribution name should be "pair"';
is_deeply $dist->releases, {
    stable =>  [qw(0.1.2 0.1.0)],
    testing => ['0.1.1'],
}, 'Releases should be correct';
is $dist->stable_version, '0.1.2', 'Should have proper stable version';
is $dist->testing_version, '0.1.1', 'Should have proper testing version';
is $dist->unstable_version, undef, 'Should have no unstable version';

