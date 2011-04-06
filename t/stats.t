#!/usr/bin/env perl -w

use strict;
use warnings;
use utf8;
use Test::More tests => 5;
#use Test::More 'no_plan';
use WWW::PGXN;
use File::Spec::Functions qw(catfile);

SEARCHER: {
    package PGXN::API::Searcher;
    $INC{'PGXN/API/Searcher.pm'} = __FILE__;
}

# Set up the WWW::PGXN object.
my $pgxn = new_ok 'WWW::PGXN', [ url => 'file:t/mirror' ];

##############################################################################
# Try to get a nonexistent stats.
ok !$pgxn->get_stats('users'),
    'Should get nothing when no stats template';

$pgxn->_uri_templates->{stats} = URI::Template->new('/stats/{name}.json');
ok !$pgxn->get_stats('nonexistent'),
    'Should get nothing when searching for a nonexistent stats';

# Fetch stats data.
ok my $stats = $pgxn->get_stats('users'), 'Get user stats';
is_deeply $stats, {
   count => 4,
   prolific => [
      {
         dist_count => 6,
         nickname => 'alexk'
      },
      {
         dist_count => 4,
         nickname => 'theory'
      },
      {
         dist_count => 1,
         nickname => 'daamien'
      },
      {
         dist_count => 1,
         nickname => 'umitanuki'
      }
   ]
}, 'Should have stats structure';
