package t::CouchDB;

use strict;
use Test::Base -Base;
use JSON::XS ();
use String::Random ();
use URI;
use CouchDB::Object;
use CouchDB::Object::Document;

our @EXPORT = qw(test_server test_dbname test_couch deploy_db);

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

sub deploy_db {
    my $couch = test_couch();
    my $name  = test_dbname();

    my $db = $couch->db($name);
    $db->create;

    my $data = do {
        open my $fh, '<', 't/docs.json' or die $!;
        local $/; <$fh>;
    };
    my $json = JSON::XS->new->decode($data);
    for (@$json) {
        my $doc = CouchDB::Object::Document->new;
        $doc->id(delete $_->{id});
        while (my ($key, $value) = each %$_) {
            $doc->$key($value);
        }
        $db->save_doc($doc);
    }

    ($name, $db);
}

1;
