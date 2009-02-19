package CouchDB::Object::Role::Serializer;

use Mouse::Role;
use Data::OpenStruct::Deep;
use JSON;

has 'serializer' => (
    is      => 'rw',
    isa     => 'JSON',
    lazy    => 1,
    default => sub { JSON->new->utf8(1) },
    handles => {
        encode_json => 'encode',
        decode_json => 'decode',
    },
);

# TODO: implements "encode_json" and "decode_json" with OpenStruct

no Mouse::Role; 1;
