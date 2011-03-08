#!/usr/bin/env perl -w

use strict;
use warnings;
use utf8;
use Test::More tests => 10;
#use Test::More 'no_plan';
use WWW::PGXN;
use File::Spec::Functions qw(catfile);

# Set up the WWW::PGXN object.
my $pgxn = new_ok 'WWW::PGXN', [ url => 'file:t/mirror' ];

##############################################################################
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
    release_info
);

is $owner->nickname, 'theory', 'Should have nickname';
is $owner->name, 'David E. Wheeler', 'Should have name';
is $owner->email, 'david@justatheory.com', 'Should have email';
is $owner->uri, 'http://justatheory.com/', 'Should have URI';
is $owner->twitter, 'theory', 'Should have twitter nick';
is_deeply $owner->release_info, {
    explanation => { stable => ["0.2.0"] },
    pair => { stable => ["0.1.0"] },
}, 'Should have release data';
