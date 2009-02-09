package CouchDB::Object::Document;

use Mouse;
use Hash::AsObject;
use Hash::Merge ();
use CouchDB::Object::JSON;

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

has '_fields' => (
    is      => 'ro',
    isa     => 'Hash::AsObject',
    # TODO: coerce
    default => sub { Hash::AsObject->new },
);

sub from_hash {
    my ($class, $hash) = @_;

    my $id  = delete $hash->{_id};
    my $rev = delete $hash->{_rev};

    my $self = $class->new(_fields => Hash::AsObject->new($hash));
    $self->id($id)   if defined $id;
    $self->rev($rev) if defined $rev;
    $self;
}

sub to_json {
    my $self = shift;
    return CouchDB::Object::JSON->encode($self->to_hash);
}

sub to_hash {
    my $self = shift;

    my $hash = {};
    $hash->{_id}  = $self->id  if $self->has_id;
    $hash->{_rev} = $self->rev if $self->has_rev;

    return Hash::Merge::merge({%{ $self->_fields }}, $hash);
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my ($key) = $AUTOLOAD =~ /([^:]+)$/;
    return $self->_fields->$key(@_);
}

sub DESTROY {}

no Mouse; __PACKAGE__->meta->make_immutable; 1;

=head1 NAME

CouchDB::Object::Document - Interface to CouchDB document

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CouchDB::Object::Database>

=cut
