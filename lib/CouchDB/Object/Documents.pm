package CouchDB::Object::Documents;

use Moose;
use CouchDB::Object;
use CouchDB::Object::Document;

has 'total_rows' => (
    is => 'rw',
    isa => 'Int',
);

has 'offset' => (
    is => 'rw',
    isa => 'Int',
);

has 'rows' => (
    is => 'rw',
    isa => 'ArrayRef',
);

no Moose;

our $VERSION = CouchDB::Object->VERSION;

sub new_from_json {
    my ($class, $json) = @_;

    my @docs = @{ $json->{rows} };
    for my $doc (@docs) {
        my $id = $doc->{id};
        $doc = CouchDB::Object::Document->new_from_json($doc->{value});
        $doc->id($id) if $id;
    }

    return $class->new(total_rows => $json->{total_rows}, offset => $json->{offset}, rows => \@docs);
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

CouchDB::Object::Documents - Interface to CouchDB documents

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CouchDB::Object::Document>

=cut
