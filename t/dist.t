#!/usr/bin/env perl -w

use strict;
use warnings;
use utf8;
use Test::More tests => 55;
#use Test::More 'no_plan';
use WWW::PGXN;
use File::Spec::Functions qw(catfile);

# Set up the WWW::PGXN object.
my $pgxn = new_ok 'WWW::PGXN', [ url => 'file:t/mirror' ];

##############################################################################
# Try to get a nonexistent distribution.
ok !$pgxn->find_distribution(name => 'nonexistent'),
    'Should get nothing when searching for a nonexistent distribution';

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
    url
    relative_url
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

##############################################################################
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

##############################################################################
# Test merging.
ok $dist = $pgxn->find_distribution(name => 'pair'),
    'Find "pair" again';
ok $dist->_merge_meta, 'Merge distmeta';

is $dist->version_for('stable'), '0.1.2', 'Should have proper stable version';
is $dist->version, '0.1.2', 'Version should be "0.1.2"';

ok $dist = $pgxn->find_distribution(name => 'pair', version => '0.1.2'),
    'Find "pair" 0.1.2 again';
ok $dist->_merge_by_dist, 'Merge by-dist';
is $dist->version_for('stable'), '0.1.2', 'Should have proper stable version';
is $dist->version, '0.1.2', 'Version should be "0.1.2"';

# Test implicit merging.
ok $dist = $pgxn->find_distribution(name => 'pair'),
    'Find "pair" once more';
is $dist->version_for('stable'), '0.1.2', 'Should have proper stable version';
is $dist->version, '0.1.2', 'Version should be "0.1.2"';

ok $dist = $pgxn->find_distribution(name => 'pair', version => '0.1.2'),
    'Find "pair" 0.1.2 once more';
is $dist->version_for('stable'), '0.1.2', 'Should have proper stable version';
is $dist->version, '0.1.2', 'Version should be "0.1.2"';

##############################################################################
# Test other methods.
ok $dist = $pgxn->find_distribution(name => 'pair', version => '0.1.1'),
    'Find pair 1.0.1';

is $dist->url, 'file:t/mirror/dist/pair/pair-0.1.1.pgz','Should have URL';
is $dist->relative_url, '/dist/pair/pair-0.1.1.pgz','Should have relative URL';

# Download to a file.
my $zip = catfile qw(t pair-0.1.1.zip);
ok !-e $zip, "$zip should not yet exist";
END { unlink $zip }
is $dist->download_to($zip), $zip, "Download to $zip";
ok -e $zip, "$zip should now exist";

# Download to a diretory.
my $pgz = catfile qw(t pair-0.1.1.pgz);
ok !-e $pgz, "$pgz should not yet exist";
END { unlink $pgz }
is $dist->download_to('t'), $pgz, 'Download to t/';
ok -e $pgz, "$pgz should now exist";
