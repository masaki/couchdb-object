use strict;
use Test::More tests => 7;

BEGIN {
    use_ok 'CouchDB::Object';
    use_ok 'CouchDB::Object::Utils';
    use_ok 'CouchDB::Object::UserAgent';
    use_ok 'CouchDB::Object::Server';
    use_ok 'CouchDB::Object::Database';
    use_ok 'CouchDB::Object::Document';
    use_ok 'CouchDB::Object::Response';
}
