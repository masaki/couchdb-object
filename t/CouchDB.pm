package t::CouchDB;

use Test::Base -Base;
use String::Random;
use CouchDB::Object::Server;
use CouchDB::Object::Database;
use CouchDB::Object::Document;

our @EXPORT = qw(server random_name);

sub server {
    my $server = $ENV{TEST_COUCHDB} || 'http://localhost:5984/';
    $server =~ s{(?<!/)$}{/};
    $server;
}

sub random_name {
    String::Random->new->randregex('[a-z]{20}');
}

1;
