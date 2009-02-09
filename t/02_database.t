# -*- mode: perl -*-
use Test::Base -Base;
use t::CouchDB;
use CouchDB::Object;
use CouchDB::Object::Database;

unless ($ENV{TEST_COUCHDB}) {
    plan skip_all => '$ENV{TEST_COUCHDB} required for network testing';
}
else {
    plan tests => 6*2;
}

my $tester = sub {
    my $db = shift;
    ok $db;

    # create and drop
    ok !$db->info;  # 404
    ok $db->create; # 201
    ok $db->info;   # 200
    ok $db->drop;   # 200
    ok !$db->info;  # 404
};

$tester->(
    CouchDB::Object->new(uri => $ENV{TEST_COUCHDB})->db(test_dbname())
);

$tester->(
    CouchDB::Object::Database->new(
        name     => test_dbname(),
        base_uri => $ENV{TEST_COUCHDB}
    )
);
