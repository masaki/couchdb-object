package CouchDB::Object::Document;

use Moose;
use Hash::AsObject;
use Hash::Merge ();
use JSON::XS ();
use CouchDB::Object;

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

has 'value' => (
    is      => 'ro',
    isa     => 'Hash::AsObject',
    # TODO: coerce
    default => sub { Hash::AsObject->new },
);

no Moose;

our $VERSION = CouchDB::Object->VERSION;

sub new_from_json {
    my ($class, $json) = @_;

    my $id    = delete $json->{_id}  || delete $json->{id};
    my $rev   = delete $json->{_rev} || delete $json->{rev};
    my $value = Hash::AsObject->new($json);

    return $class->new(id => $id, rev => $rev, value => $value);
}

sub to_json {
    my $self = shift;

    my $hash = {};
    $hash->{_id}  = $self->id  if $self->has_id;
    $hash->{_rev} = $self->rev if $self->has_rev;

    $hash = Hash::Merge::merge({%{ $self->value }}, $hash);
    return JSON::XS->new->encode($hash);
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my ($key) = $AUTOLOAD =~ /([^:]+)$/;
    return $self->value->$key(@_);
}

sub DESTROY {}

__PACKAGE__->meta->make_immutable;

1;

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
