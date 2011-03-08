#!/usr/bin/env perl -w

use strict;
use warnings;
use Test::More tests => 16;
#use Test::More 'no_plan';
use File::Spec::Functions qw(catfile);

my $CLASS;
BEGIN {
    $CLASS = 'WWW::PGXN';
    use_ok $CLASS or die;
}

my $pgxn = new_ok $CLASS, [ url => 'http://api.pgxn.org/' ];
is $pgxn->url, 'http://api.pgxn.org', 'Should have the URL';
is $pgxn->proxy, undef, 'Should have no proxy';

##############################################################################
# Test the request object.
isa_ok $pgxn->_request, 'HTTP::Tiny', 'The request object';

# Switch to local files.
ok $pgxn->url('file:t/mirror'), 'Switch to local mirror';
isa_ok my $req = $pgxn->_request, 'WWW::PGXN::FileReq', 'The request object';

##############################################################################
# Test FileReq.
ok my $res = $req->get('file:t/nonexistent.txt'),
    'Fetch nonexisent file';
is_deeply $res, {
    success => 0,
    status  => 404,
    reason  => 'not found',
    headers => {},
}, 'Should have "not found" response';

my $f = catfile qw(t mirror index.json);
open my $fh, '<:raw', $f or die "Cannot open $f: $!\n";
my $json = do {
    local $/;
    <$fh>;
};
close $fh;

ok $res = $req->get('file:t/mirror/index.json'), 'Fetch index.html';
is_deeply $res, {
    success => 1,
    status  => 200,
    reason  => 'OK',
    content => $json,
    headers => {},
}, 'Should have the content response';

##############################################################################
# Test the templates. Start with a bogus URL.
$pgxn->url('file:t');
local $@;
eval { $pgxn->_uri_templates };
like $@, qr{Request for file:t/index\.json failed: 404: not found},
    'Should get exception for bad templates URL';

# Now get the real thing.
$pgxn->url('file:t/mirror');
ok my $tmpl =  $pgxn->_uri_templates, 'Get the URI templates';
my $data = JSON->new->utf8->decode($json);
$data->{mirrors} = '/meta/mirrors.json';
is_deeply $tmpl, { map { $_ => URI::Template->new($data->{$_}) } keys %{ $data } },
    'Should have all the templates';

##############################################################################
# Test url formatting.
is $pgxn->_url_for('by-dist', dist => 'pair'),
    'file:t/mirror/by/dist/pair.json',
    '_url_for() should work';

local $@;
eval { $pgxn->_url_for('nonexistent') };
like $@, qr{No URI template named "nonexistent"},
    'Should get error for nonexistent URI template';
