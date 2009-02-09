package t::CouchDB;

use strict;
use warnings;
use Exporter 'import';
use String::Random;
use CouchDB::Object;

our @EXPORT = qw(
    test_dbname
    test_couch
    test_db
);

sub test_dbname {
    String::Random->new->randregex('[a-z]{20}');
}

sub test_couch {
    CouchDB::Object->new(uri => $ENV{TEST_COUCHDB});
}

sub test_db {
    my $db = CouchDB::Object->new(uri => $ENV{TEST_COUCHDB})->db(test_dbname());
    $db->create;
    $db;
}

1;
