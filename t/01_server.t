# -*- mode: perl -*-
use Test::Base -Base;
use CouchDB::Object;

unless ($ENV{TEST_COUCHDB}) {
    plan skip_all => '$ENV{TEST_COUCHDB} required for network testing';
}
else {
    plan tests => 2;
}

my $couch = CouchDB::Object->new(uri => $ENV{TEST_COUCHDB});
ok $couch;
ok $couch->info;
