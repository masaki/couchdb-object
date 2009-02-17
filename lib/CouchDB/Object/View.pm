package CouchDB::Object::View;

use Mouse;

has 'name' => (
    is  => 'rw',
    isa => 'Str',
);

has 'map' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_map',
);

has 'reduce' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_reduce',
);

no Mouse; __PACKAGE__->meta->make_immutable;
