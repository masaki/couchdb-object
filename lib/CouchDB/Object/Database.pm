package CouchDB::Object::Database;

use Mouse;
use MouseX::Types::URI;
use CouchDB::Object::Document;

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

=comment
sub all_docs {
    my ($self, $args) = @_;
    return $self->request(GET => $self->uri_for('_all_docs', $args));
}

sub bulk_docs {
    my ($self, $docs) = @_;

    my $body = { docs => [ map { $_->to_hash } @$docs ] };
    $body = CouchDB::Object::JSON->encode($body);

    my $header = HTTP::Headers->new('Content-Type' => 'application/json');
    my $res = $self->request(POST => $self->uri_for('_bulk_docs'), $header, $body);

    # merge
    if ($res->is_success) {
        my $ea = each_array(@$docs, @{ $res->content->{new_revs} });
        while (my ($doc, $content) = $ea->()) {
            $doc->id($content->{id})   if exists $content->{id};
            $doc->rev($content->{rev}) if exists $content->{rev};
        }
    }

    return $res;
}

sub query {
    my ($self, $map, $reduce, $lang, $args) = @_;

    my $body = {
        language => $lang || (ref $map eq 'CODE') ? 'text/perl' : 'javascript',
        map      => _code2str($map),
    };
    $body->{reduce} = _code2str($reduce) if $reduce;
    $body = CouchDB::Object::JSON->encode($body);

    my $header = HTTP::Headers->new('Content-Type' => 'application/json');
    return $self->request(POST => $self->uri_for('_temp_view', $args), $header, $body);
}

sub view {
    my ($self, $name, $args) = @_;
    return $self->request(GET => $self->uri_for('_view', split(m!/!, $name), $args));
}

# from CouchDB::View::Document
sub _code2str {
    require Data::Dump::Streamer;
    ref $_[0]
        ? sprintf 'do { my $CODE1; %s; $CODE1 }', Data::Dump::Streamer->new->Data($_[0])->Out
        : $_[0];
}

=cut

no Mouse; __PACKAGE__->meta->make_immutable; 1;

=head1 NAME

CouchDB::Object::Database - Interface to CouchDB database

=head1 SYNOPSIS

=head1 METHODS

=head2 new(name => $dbname, server => $uri)

Returns the L<CouchDB::Object::Database> object

=head2 name

Returns the database name

=head2 uri

Returns the database uri

=head2 create

=head2 drop

=head2 info

=head2 compact

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CouchDB::Object::Document>, L<CouchDB::Object::Response>

=cut
