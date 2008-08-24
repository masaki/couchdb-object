package CouchDB::Object::Documents;

use Moose;
use MooseX::AttributeHelpers;
use CouchDB::Object;
use CouchDB::Object::Document;

has 'total_docs' => (
    is      => 'rw',
    isa     => 'Int',
    default => sub { 0 },
);

has 'offset' => (
    is      => 'rw',
    isa     => 'Int',
    default => sub { 0 },
);

has 'docs' => (
    metaclass  => 'Collection::List',
    is         => 'rw',
    isa        => 'ArrayRef[CouchDB::Object::Document]',
    auto_deref => 1,
    provides   => { count => 'count' },
);

no Moose;

our $VERSION = CouchDB::Object->VERSION;

sub new_from_json {
    my ($class, $json) = @_;

    my @docs = grep { exists $_->{id} and exists $_->{value} } @{ $json->{rows} };
    for my $doc (@docs) {
        my $id = delete $doc->{id};
        $doc = CouchDB::Object::Document->new_from_json($doc->{value});
        $doc->id($id) if defined $id;
    }

    return $class->new(
        total_docs => $json->{total_rows},
        offset     => $json->{offset},
        docs       => \@docs,
    );
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
