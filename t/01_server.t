use strict;
use t::CouchDB;

my $couch = test_couch();

unless ($couch->ping) {
    plan skip_all => "Can't connect CouchDB server: " . test_server();
}
else {
    plan tests => 2;
}

is $couch->uri => test_server();
isa_ok $couch->db(test_dbname()) => 'CouchDB::Object::Database';
