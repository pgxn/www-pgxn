#!/usr/bin/env perl -w

use strict;
use warnings;
use utf8;
use Test::More tests => 31;
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
    new
    abstract
    license
    name
    version
    description
    generated_by
    no_index
    prereqs
    provides
    release_date
    release_status
    resources
    sha1
    owner
    releases
    tags
    maintainers
    versions_for
    version_for
);
is $dist->{_pgxn}, $pgxn, 'It should contain the WWW::PGXN object';

# Examine the distribution data.
is $dist->name, 'pair', 'Distribution name should be "pair"';
is_deeply $dist->releases, {
    stable =>  [qw(0.1.2 0.1.0)],
    testing => ['0.1.1'],
}, 'Releases should be correct';
is $dist->version_for('stable'), '0.1.2', 'Should have proper stable version';
is $dist->version_for('testing'), '0.1.1', 'Should have proper testing version';
is $dist->version_for('unstable'), undef, 'Should have no unstable version';

is_deeply [$dist->versions_for('stable')], [qw(0.1.2 0.1.0)],
    'Should have stable versions';
is_deeply [ $dist->versions_for('testing') ], [qw(0.1.1)],
  'Should have testing versions';
is_deeply [ $dist->versions_for('unstable') ], [],
  'Should have no unstable versions';

# Now find for a particular version number.
ok $dist = $pgxn->find_distribution(name => 'pair', version => '0.1.2'),
    'Find pair 0.1.2';
isa_ok $dist, 'WWW::PGXN::Distribution', 'It';
is $dist->name, 'pair', 'Name should be "pair"';
is $dist->version, '0.1.2', 'Version should be "0.1.2"';
is $dist->abstract, 'A key/value pair dåtå type', 'Should have abstrct';
is $dist->description, 'This library contains a single PostgreSQL extension called `pair`.',
    'Should have description';
is $dist->release_date, '2010-11-10T12:18:03Z', 'Should have release date';
is $dist->release_status, 'stable', 'Should have release status';
is $dist->owner, 'theory', 'Should have owner';
is $dist->license, 'postgresql', 'Should have license';
is $dist->sha1, 'cebefd23151b4b797239646f7ae045b03d028fcf', 'Should have SHA1';
is_deeply [$dist->maintainers], ['David E. Wheeler <david@justatheory.com>'],
    'Should have maintainers';
is_deeply [$dist->tags], ['ordered pair', 'pair', 'key value'],
    'Should have tags';
is $dist->generated_by, undef, 'generated_by should be undef';
is_deeply $dist->no_index, {}, 'Should have empty no-index';
is_deeply $dist->prereqs, {}, 'Should have empty prereqs';
is_deeply $dist->provides, {
    pair => {
         abstract => 'A key/value pair dåtå type',
         file => 'sql/pair.sql',
         version => '0.1.2'
      }
}, 'Should have provides';

is_deeply $dist->resources, {
    bugtracker => {
        web => 'http://github.com/theory/kv-pair/issues/'
    },
    repository => {
        type => 'git',
        url => 'git://github.com/theory/kv-pair.git',
        web => 'http://github.com/theory/kv-pair/'
    }
}, 'Should have resources';

# delete $dist->{_pgxn};
# use Data::Dump; ddx $dist;
