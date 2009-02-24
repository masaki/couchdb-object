# -*- mode: perl -*-
use Test::Base;
use String::Random ();
use CouchDB::Object;

plan skip_all => '$ENV{TEST_COUCHDB} required for network testing' unless $ENV{TEST_COUCHDB};
plan tests => 8;

my $base_uri = $ENV{TEST_COUCHDB};
my $couch = CouchDB::Object->new(uri => $base_uri);

# relax with couchdb
ok $couch;
is $couch->uri => $base_uri;
ok $couch->info;
ok $couch->version;

SKIP: {
    my ($major, $minor, $teeny) = split /\./, $couch->version;
    skip 'required over 0.8.0', 4
        unless $major > 0 or ($major == 0 and $minor >= 8);

    my $dbname = String::Random->new->randregex("[0-9a-z]{20}");

    my $db = $couch->db($dbname);
    ok $db;
    isa_ok $db => 'CouchDB::Object::Database';
    is $db->name => $dbname;
    is $db->uri => "${base_uri}${dbname}/";
}
