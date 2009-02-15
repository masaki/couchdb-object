package CouchDB::Object::Iterator;

use Mouse;
use CouchDB::Object::Document;

sub next {
}

sub reset {
}

sub all {
}

no Mouse; __PACKAGE__->meta->make_immutable; 1;
