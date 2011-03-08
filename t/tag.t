#!/usr/bin/env perl -w

use strict;
use warnings;
use utf8;
use Test::More tests => 6;
#use Test::More 'no_plan';
use WWW::PGXN;
use File::Spec::Functions qw(catfile);

# Set up the WWW::PGXN object.
my $pgxn = new_ok 'WWW::PGXN', [ url => 'file:t/mirror' ];

##############################################################################
# Fetch tag data.
ok my $tag = $pgxn->find_tag('key value'),
    'Find tag "key value"';
isa_ok $tag, 'WWW::PGXN::Tag', 'It';
can_ok $tag, qw(
    new
    name
    release_info
);

is $tag->name, 'key value', 'Should have name';
is_deeply $tag->release_info, {
    pair  => { stable => ['0.1.0'], testing => ['0.1.1'] },
    pgTAP => { stable => ['0.25.0'] },
}, 'Should have release data';
