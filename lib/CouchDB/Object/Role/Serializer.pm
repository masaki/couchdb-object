package CouchDB::Object::Role::Serializer;

use Mouse::Role;
use Data::OpenStruct::Deep;
use JSON ();

has 'serializer' => (
    is      => 'rw',
    isa     => 'JSON',
    lazy    => 1,
    default => sub { JSON->new->utf8(1) },
);

sub encode_json {
    my ($self, $args) = @_;

    my $data = blessed $args ? $args->to_hash : $args;
    return $self->serializer->encode($data);
}

sub decode_json {
    my ($self, $json) = @_;

    my $data = $self->serializer->decode($json);
    if (ref $data eq 'HASH') {
        $data = Data::OpenStruct::Deep->new($data);
    }

    return $data;
}

no Mouse::Role; 1;
