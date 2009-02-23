package CouchDB::Object::DocumentSet;

use Mouse;
use Array::Iterator;
use CouchDB::Object::Document;

has 'rows' => (
    is         => 'rw',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [] },
    trigger    => sub { shift->reset },
);

has 'total_rows' => (
    is  => 'rw',
    isa => 'Int',
);

has 'offset' => (
    is  => 'rw',
    isa => 'Int',
);

has 'iterator' => (
    is      => 'rw',
    isa     => 'Array::Iterator',
    handles => { next => 'getNext' },
);

sub count {
    my $self = shift;
    return scalar @{ $self->rows };
}

sub reset {
    my $self = shift;
    $self->iterator(Array::Iterator->new($self->rows));
}

sub all {
    my $self = shift;
    $self->reset;
    return @{ $self->rows };
}

no Mouse; __PACKAGE__->meta->make_immutable;

=head1 NAME

CouchDB::Object::Iterator - Interface to CouchDB documents

=head1 METHODS

=head2 total_rows

=head2 offset

=head2 count

=head2 all

=head2 next

=head2 reset

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CouchDB::Object::Database>

=cut
