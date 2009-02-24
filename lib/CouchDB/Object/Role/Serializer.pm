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
    return $self->serializer->decode($json);
}

sub decode_json_to_object {
    my ($self, $json) = @_;

    my $hash = $self->decode_json($json);
    my $args = {};
    while (my ($key, $value) = each %$hash) {
        $args->{$key} = JSON::is_bool($value) ? $value + 0 : $value;
    }

    return Data::OpenStruct::Deep->new($args);
}

no Mouse::Role; 1;
