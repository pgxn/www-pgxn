#!/usr/bin/env perl

use strict;
use Test::More;
eval "use Test::Spelling";
plan skip_all => "Test::Spelling required for testing POD spelling" if $@;

add_stopwords(<DATA>);
all_pod_files_spelling_ok();

__DATA__
PostgreSQL
RDBMS
postgresql
UTC
SHA
Prereq
lifecycle
browsable
UTF
pgxn
GitHub
API
metadata
JSON
CPAN
dists
