package CouchDB::Object::Iterator;

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

has 'iterator' => (
    is      => 'rw',
    isa     => 'Array::Iterator',
    handles => { next => 'getNext' },
);

sub BUILDARGS {
    my ($class, $rows) = @_;

    my @docs;
    for my $row (@$rows) {
        my $value = $row->{value} || {};

        my $id = $row->{id};
        if (exists $value->{_id}) {
            $id = delete $value->{_id};
        }

        my $rev;
        if (exists $value->{rev}) {
            $rev = delete $value->{rev};
        }
        elsif (exists $value->{_rev}) {
            $rev = delete $value->{_rev};
        }

        my $doc = CouchDB::Object::Document->new($value);
        $doc->id($id)   if defined $id;
        $doc->rev($rev) if defined $rev;
        push @docs, $doc;
    }

    return { rows => \@docs };
}

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
