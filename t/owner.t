#!/usr/bin/env perl -w

use strict;
use warnings;
use Test::More tests => 11;
#use Test::More 'no_plan';
use WWW::PGXN;

# Set up the WWW::PGXN object.
my $pgxn = new_ok 'WWW::PGXN', [ url => 'file:t/mirror' ];

##############################################################################
# Try to get a nonexistent owner.
ok !$pgxn->find_owner('nonexistent'),
    'Should get nothing when searching for a nonexistent owner';

# Fetch owner data.
ok my $owner = $pgxn->find_owner('theory'),
    'Find owner "theory"';
isa_ok $owner, 'WWW::PGXN::Owner', 'It';
can_ok $owner, qw(
    new
    nickname
    name
    email
    uri
    twitter
    releases
);

is $owner->nickname, 'theory', 'Should have nickname';
is $owner->name, 'David E. Wheeler', 'Should have name';
is $owner->email, 'david@justatheory.com', 'Should have email';
is $owner->uri, 'http://justatheory.com/', 'Should have URI';
is $owner->twitter, 'theory', 'Should have twitter nick';
is_deeply $owner->releases, {
    explanation => { stable => [
        {version => "0.2.0", date => '2011-02-21T20:14:56Z'},
    ] },
    pair => { stable => [
        {version => "0.1.0", date => '2010-10-19T03:59:54Z'},
    ] },
}, 'Should have release data';
