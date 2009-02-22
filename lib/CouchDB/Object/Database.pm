package CouchDB::Object::Database;

use Mouse;
use MouseX::Types::URI;
use List::MoreUtils qw(each_array);
use CouchDB::Object;
use CouchDB::Object::Document;
use CouchDB::Object::Iterator;
use namespace::clean -except => ['meta'];

with 'CouchDB::Object::Role::UriFor';

has 'couch' => (
    is       => 'rw',
    isa      => 'CouchDB::Object',
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

has 'uri' => (
    is     => 'rw',
    isa    => 'URI',
    coerce => 1,
);

sub BUILD {
    my $self = shift;

    my $uri = $self->couch->uri->clone;
    $uri->path($uri->path . $self->name . '/');
    $self->uri($uri->canonical);
}

# database
sub create {
    my $self = shift;
    return $self->http_put($self->uri)->is_success;
}

sub info {
    my $self = shift;
    my $res = $self->http_get($self->uri);
    return $res->is_success
        ? $self->decode_json($res->decoded_content)
        : undef;
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
    my ($self, $id, $args) = @_;

    my $res = $self->http_get($self->uri_for($id, $args || {}));
    return unless $res->is_success;

    my $doc = $self->decode_json($res->decoded_content);
    return CouchDB::Object::Document->new($doc);
}

sub save_doc {
    my ($self, $doc, $args) = @_;

    my $res;
    if ($doc->has_id) {
        my $uri = $self->uri_for($doc->id, $args || {});
        $res = $self->http_put($uri, $doc->to_json);
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
    my $uri = $self->uri_for($doc->id, $query);
    return $self->http_delete($uri)->is_success;
}

# documents
sub all_docs {
    my ($self, $args) = @_;

    my $query = $args || {};
    # TODO: filter_query
    my $res = $self->http_get($self->uri_for('_all_docs', $query));
    return unless $res->is_success;

    my $content = $self->decode_json($res->decoded_content);
    return CouchDB::Object::Iterator->new($content->rows);
}

sub bulk_docs {
    my $self = shift;
    my @docs = ref $_[0] eq 'ARRAY' ? @{$_[0]} : @_;

    my $body = $self->encode_json({ docs => [ map { $_->to_hash } @docs ] });
    my $res = $self->http_post($self->uri_for('_bulk_docs'), $body);
    return unless $res->is_success;

    # merge
    my $contents = $self->decode_json($res->decoded_content);
    my @new_revs = @{ $contents->new_revs };
    if (@docs == @new_revs) {
        my $ea = each_array(@docs, @new_revs);
        while (my ($doc, $new) = $ea->()) {
            $doc->id($new->{id})   if exists $new->{id};
            $doc->rev($new->{rev}) if exists $new->{rev};
        }
    }

    return wantarray ? @docs : \@docs;
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
