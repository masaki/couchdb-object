use strict;
use Test::More tests => 5;

BEGIN {
    use_ok 'CouchDB::Object';
    use_ok 'CouchDB::Object::Database';
    use_ok 'CouchDB::Object::Document';
    use_ok 'CouchDB::Object::Response';
    use_ok 'CouchDB::Object::UserAgent';
}
