package CouchDB::Object::Database;

use Mouse;
use MouseX::Types::URI;
use List::MoreUtils ();
use CouchDB::Object::Document;
use CouchDB::Object::Iterator;

with qw(
    CouchDB::Object::Role::UserAgent
    CouchDB::Object::Role::Serializer
);

has 'name' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'base_uri' => (
    is       => 'rw',
    isa      => 'URI',
    coerce   => 1,
    required => 1,
);

sub uri {
    my $self = shift;

    my $uri = $self->base_uri->clone;
    $uri->path($uri->path . $self->name . '/');
    $uri->canonical;
}

# database
sub create {
    my $self = shift;

    my $res = $self->ua->put($self->uri, Accept => 'application/json');
    return $res->is_success;
}

sub info {
    my $self = shift;

    my $res = $self->ua->get($self->uri, Accept => 'application/json');
    return unless $res->is_success;
    return $self->deserialize($res->decoded_content);
}

sub drop {
    my $self = shift;

    my $res = $self->ua->delete($self->uri, Accept => 'application/json');
    return $res->is_success;
}

sub compact {
    # TODO: implements
}

# document
sub open_doc {
    my ($self, $doc, $args) = @_;

    my $id = blessed $doc ? $doc->id : $doc;
    my $query = $args || {};
    my $res = $self->ua->get($self->uri_for($id, $query), Accept => 'application/json');
    return unless $res->is_success;
    return CouchDB::Object::Document->new($self->deserialize($res->decoded_content));
}

sub save_doc {
    my ($self, $doc, $args) = @_;

    my %params = (
        Accept       => 'application/json',
        Content_Type => 'application/json',
        Content      => $doc->to_json,
    );

    my $res;
    if ($doc->has_id) {
        my $query = $args || {};
        $res = $self->ua->put($self->uri_for($doc->id, $query), %params);
    }
    else {
        $res = $self->ua->post($self->uri, %params);
    }

    return unless $res->is_success;

    # merge
    my $content = $self->deserialize($res->decoded_content);
    $doc->id($content->{id})   if exists $content->{id};
    $doc->rev($content->{rev}) if exists $content->{rev};
    return $doc;
}

sub remove_doc {
    my ($self, $doc, $args) = @_;

    return unless $doc->has_id and $doc->has_rev;

    my $query = { %{ $args || {} }, rev => $doc->rev };
    my $res = $self->ua->delete($self->uri_for($doc->id, $query), Accept => 'application/json');
    return $res->is_success;
}

# documents
sub all_docs {
    my ($self, $args) = @_;

    my $query = $args || {};
    my $res = $self->ua->get($self->uri_for('_all_docs', $query), Accept => 'application/json');
    return unless $res->is_success;

    my $content = $self->deserialize($res->decoded_content);
    return CouchDB::Object::Iterator->new($content->{rows});
}

sub bulk_docs {
    my ($self, $docs) = @_;

    my $body = { docs => [ map { $_->to_hash } @$docs ] };
    my %params = (
        Accept       => 'application/json',
        Content_Type => 'application/json',
        Content      => $self->serialize($body),
    );

    my $res = $self->ua->post($self->uri_for('_bulk_docs'), %params);
    return unless $res->is_success;

    # merge
    my $contents = $self->deserialize($res->decoded_content);
    my @new_revs = @{ $contents->{new_revs} };
    if (@$docs == @new_revs) {
        my $ea = List::MoreUtils::each_array(@$docs, @new_revs);
        while (my ($doc, $new) = $ea->()) {
            $doc->id($new->{id})   if exists $new->{id};
            $doc->rev($new->{rev}) if exists $new->{rev};
        }
    }

    return $docs;
}

sub query {
    # TODO: implements
}

sub view {
    # TODO: implements
}

no Mouse; __PACKAGE__->meta->make_immutable;

=head1 NAME

CouchDB::Object::Database - Interface to CouchDB database

=head1 SYNOPSIS

=head1 DESCRIPTION

This module is an interface to CouchDB database.
This module can populate database and documents within the database.

=head1 METHODS

=head2 new(name => $dbname, base_uri => $uri)

Returns the L<CouchDB::Object::Database> object.

=head2 name

Returns the name of the database.

=head2 base_uri

Returns the base URI of the database.

=head2 uri

Returns the URI of the database.

=head2 create

Creates the database. It returns C<true> if succeeded.

=head2 drop

Deletes the database. It returns C<true> if succeeded.

=head2 info

Returns the information C<HashRef> of the database or C<undef>.

=head2 open_doc($id, \%args?)

Returns the document by C<$id>.

=head2 save_doc($doc, \%args?)

Creates or updates the specified document C<$doc>.

=head2 remove_doc($doc, \%args?)

Deletes the specified document C<$doc>.

=head2 all_docs(\%args?)

=head2 bulk_docs(\@docs)

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CouchDB::Object::Document>, L<CouchDB::Object::Iterator>

=cut
