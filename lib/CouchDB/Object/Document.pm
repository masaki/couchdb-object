package CouchDB::Object::Document;

use Mouse;
use Data::OpenStruct::Deep;

with 'CouchDB::Object::Role::Serializer';

has 'id' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_id',
);

has 'rev' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_rev',
);

has 'deleted' => (
    is        => 'rw',
    isa       => 'Bool',
    default   => 0,
);

has '__fields' => (
    is      => 'rw',
    isa     => 'Data::OpenStruct::Deep',
    lazy    => 1,
    default => sub { Data::OpenStruct::Deep->new },
);

sub BUILDARGS {
    my ($self, %args) = @_;
    return {} unless keys %args;

    my $fields = {};
    for my $name (keys %args) {
        next if $self->meta->has_attribute($name);
        $fields->{$name} = delete $args{$name};
    }

    $args{__fields} = Data::OpenStruct::Deep->new($fields);

    return \%args;
}

sub from_hash {
    my ($class, $args) = @_;

    my $hash = (blessed $args ? $args->to_hash : $args) || {};
    my $self = $class->new;

    while (my ($key, $value) = each %$hash) {
        $key =~ s/^_//;
        $self->$key($value);
    }

    return $self;
}

sub to_hash {
    my $self = shift;

    my $hash = $self->__fields->to_hash;
    $hash->{_id}  = $self->id  if $self->has_id;
    $hash->{_rev} = $self->rev if $self->has_rev;
    $hash->{_deleted} = \1 if $self->deleted;

    return $hash;
}

sub to_json {
    my $self = shift;
    return $self->encode_json($self->to_hash);
}

our $AUTOLOAD;
sub AUTOLOAD {
    my ($self, $value) = @_;

    my ($key) = $AUTOLOAD =~ /([^:]+)$/;
    return if $key eq 'DESTROY';

    $self->__fields->$key($value);
}

no Mouse; __PACKAGE__->meta->make_immutable;

=head1 NAME

CouchDB::Object::Document - Interface to CouchDB document

=head1 METHODS

=head2 new($json?)

=head2 id($id?)

=head2 rev($rev?)

=head2 to_json

=head2 to_hash

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CouchDB::Object::Database>

=cut
