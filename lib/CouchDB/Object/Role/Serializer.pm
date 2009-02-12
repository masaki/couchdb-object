package CouchDB::Object::Role::Serializer;

use Mouse::Role;

has 'serializer' => (
    is      => 'rw',
    isa     => 'JSON',
    lazy    => 1,
    default => sub {
        require JSON;
        JSON->new->utf8(1);
    },
    handles => {
        serialize   => 'encode',
        deserialize => 'decode',
    },
);

no Mouse::Role; 1;
