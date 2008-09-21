package t::CouchDB;

use Test::Base -Base;
use String::Random ();
use URI;
use CouchDB::Object;
use CouchDB::Object::Document;
use CouchDB::Object::JSON;

our @EXPORT = qw(
    test_server test_dbname test_couch
    read_json
);

sub read_json() {
    open my $fh, shift or die $!;
    my $data = join '', <$fh>;
    return CouchDB::Object::JSON->instance->decode($data);
}

sub test_server {
    my $uri = URI->new($ENV{TEST_COUCHDB} || 'http://localhost:5984/');
    $uri->path('/');
    $uri;
}

sub test_dbname {
    String::Random->new->randregex('[a-z]{20}');
}

sub test_couch {
    my $uri = test_server();
    CouchDB::Object->new(scheme => $uri->scheme, host => $uri->host, port => $uri->port);
}

1;
