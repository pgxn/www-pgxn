#!/usr/bin/env perl -w

use strict;
use warnings;
use utf8;
use Test::More tests => 28;
#use Test::More 'no_plan';
use WWW::PGXN;
use File::Spec::Functions qw(catfile);

# Set up the WWW::PGXN object.
my $pgxn = new_ok 'WWW::PGXN', [ url => 'file:t/mirror' ];

##############################################################################
# Fetch extension data.
ok my $ext = $pgxn->find_extension('pair'),
    'Find extension "pair"';
isa_ok $ext, 'WWW::PGXN::Extension', 'It';
can_ok $ext, qw(
    new
    name
    latest
    stable_info
    testing_info
    unstable_info
    latest_info
    stable_distribution
    testing_distribution
    unstable_distribution
    latest_distribution
    distribution_for_version
    info_for_version
);

is $ext->name, 'pair', 'Name should be "pair"';
is $ext->latest, 'stable', 'Latest should be "stable"';
ok my $dist = $ext->stable_distribution, 'Get the stable distribution';
isa_ok $dist, 'WWW::PGXN::Distribution', 'It';
is $dist->name, 'pair', 'It should be the "pair" distribution';
is $dist->version, '0.1.0', 'It should be v0.1.0';

ok $dist = $ext->latest_distribution, 'Get the latest distribution';
isa_ok $dist, 'WWW::PGXN::Distribution', 'It';
is $dist->name, 'pair', 'It should be the "pair" distribution';
is $dist->version, '0.1.0', 'It should be v0.1.0';

is $ext->testing_distribution, undef, 'Should have no testing distribution';
is $ext->unstable_distribution, undef, 'Should have no unstable distribution';

# Fetch for verions.
ok $dist = $ext->distribution_for_version('0.1.0'),
    'Get the distribution for pair 0.1.0';
isa_ok $dist, 'WWW::PGXN::Distribution', 'It';
is $dist->name, 'pair', 'It should be the "pair" distribution';
is $dist->version, '0.1.0', 'It should be v0.1.0';

ok $dist = $ext->distribution_for_version('0.0.5'),
    'Get the distribution for pair 0.0.5';
isa_ok $dist, 'WWW::PGXN::Distribution', 'It';
is $dist->name, 'pair', 'It should be the "pair" distribution';
is $dist->version, '0.1.1', 'It should be v0.1.1';

# Check status data.
is_deeply $ext->stable_info, { dist => 'pair', version => '0.1.0' },
    'Should have stable data';
is_deeply $ext->latest_info, { dist => 'pair', version => '0.1.0' },
    'Should have latest data';
is_deeply $ext->testing_info, {}, 'Should have empty testing info';
is_deeply $ext->unstable_info, {}, 'Should have empty unstable info';
