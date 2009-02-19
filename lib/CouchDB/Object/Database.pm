package CouchDB::Object::Database;

use Mouse;
use List::MoreUtils ();
use CouchDB::Object;
use CouchDB::Object::Document;
use CouchDB::Object::Iterator;

has 'couch' => (
    is       => 'rw',
    isa      => 'CouchDB::Object',
    weak_ref => 1,
    required => 1,
    handles  => [qw(
        http_get http_post http_put http_delete
        decode_json encode_json
    )],
);

has 'name' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

sub uri {
    my $self = shift;

    my $uri = $self->couch->uri->clone;
    $uri->path($uri->path . $self->name . '/');
    $uri->canonical;
}

# database
sub create {
    my $self = shift;
    return $self->http_put($self->uri)->is_success;
}

sub info {
    my $self = shift;
    my $res = $self->http_get($self->uri);
    return $res->is_success ? $self->decode_json($res->decoded_content) : undef;
}

sub drop {
    my $self = shift;
    return $self->http_delete($self->uri)->is_success;
}

sub compact {
    # TODO: implements
}

# document
sub open_doc {
    my ($self, $doc, $args) = @_;

    my $id = blessed $doc ? $doc->id : $doc;
    my $res = $self->http_get($self->uri_for($id, $args || {}));
    return unless $res->is_success;
    return CouchDB::Object::Document->new($self->decode_json($res->decoded_content));
}

sub save_doc {
    my ($self, $doc, $args) = @_;

    my $res;
    if ($doc->has_id) {
        my $query = $args || {};
        $res = $self->http_put($self->uri_for($doc->id, $query), $doc->to_json);
    }
    else {
        $res = $self->http_post($self->uri, $doc->to_json);
    }

    return unless $res->is_success;

    # merge
    my $content = $self->decode_json($res->decoded_content);
    $doc->id($content->id)   if defined $content->id;
    $doc->rev($content->rev) if defined $content->rev;
    return $doc;
}

sub remove_doc {
    my ($self, $doc, $args) = @_;

    return unless $doc->has_id and $doc->has_rev;

    my $query = { %{ $args || {} }, rev => $doc->rev };
    return $self->http_delete($self->uri_for($doc->id, $query))->is_success;
}

# documents
sub all_docs {
    my ($self, $args) = @_;

    my $query = $args || {};
    # TODO: filer_query
    my $res = $self->http_get($self->uri_for('_all_docs', $query));
    return unless $res->is_success;

    my $content = $self->decode_json($res->decoded_content);
    return CouchDB::Object::Iterator->new($content->rows);
}

sub bulk_docs {
    my ($self, $docs) = @_;

    my $body = { docs => [ map { $_->to_hash } @$docs ] };
    my $res = $self->http_post($self->uri_for('_bulk_docs'), $self->encode_json($body));
    return unless $res->is_success;

    # merge
    my $contents = $self->decode_json($res->decoded_content);
    my @new_revs = @{ $contents->new_revs };
    if (@$docs == @new_revs) {
        my $ea = List::MoreUtils::each_array(@$docs, @new_revs);
        while (my ($doc, $new) = $ea->()) {
            $doc->id($new->id)   if defined $new->id;
            $doc->rev($new->rev) if defined $new->rev;
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

sub _filter_query {
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
