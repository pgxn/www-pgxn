#!/usr/bin/env perl -w

use strict;
use warnings;
#use Test::More tests => 11;
use Test::More 'no_plan';
use Test::MockModule;
use WWW::PGXN;

my @params;
SEARCHER: {
    package PGXN::API::Searcher;
    $INC{'PGXN/API/Searcher.pm'} = __FILE__;
    sub new { bless {} => shift }
    sub search { shift; @params = @_; return { foo => 1 } };
}

# Set up the WWW::PGXN object.
my $pgxn = new_ok 'WWW::PGXN', [ url => 'http://api.pgxn.org/' ];

# Make sure the search methods dispatch as they should.
my $fetched_url;
my $mocker = Test::MockModule->new('WWW::PGXN');
$mocker->mock(_fetch => sub {
    $fetched_url = $_[1];
    return { content => '{"foo":"bar"}' };
});

my $query = { query  => 'whü', offset => 2, limit  => 10 };
ok my $res = $pgxn->search($query), 'Search';
is_deeply $res, {foo => 'bar'}, 'Should have the results';
is $fetched_url, 'http://api.pgxn.org/by/?l=10&q=wh%C3%BC&o=2',
    'Should have requested the proper URL';

# Now make sure that the file system does the right thing.
ok $pgxn->url('file:t/mirror'), 'Set a file: URL';
$mocker->unmock_all;

ok $res = $pgxn->search($query), 'Search via file: URL';
is_deeply $res, {foo => 1}, 'Should have the results';
is_deeply \@params, [doc => $query], 'Searcher shoudld have got proper args';
