package CouchDB::Object::Database;

use Moose;
use MooseX::Types::URI qw(Uri);
use CouchDB::Object;
use CouchDB::Object::UserAgent;
use CouchDB::Object::Utils qw(uri_for);

has 'name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'uri' => (
    is       => 'ro',
    isa      => Uri,
    coerce   => 1,
    required => 1,
);

has 'agent' => (
    is       => 'ro',
    isa      => 'CouchDB::Object::UserAgent',
    required => 1,
    default  => sub { CouchDB::Object::UserAgent->new },
);

no Moose;

our $VERSION = CouchDB::Object->VERSION;

sub BUILD {
    my ($self, $args) = @_;
    $self->uri->$_(undef) for qw(query fragment);
}

sub create {
    my $self = shift;
    return $self->agent->put($self->uri);
}

sub drop {
    my $self = shift;
    return $self->agent->delete($self->uri);
}

sub info {
    my $self = shift;
    return $self->agent->get($self->uri);
}

sub compact {
    # TODO: implements
}

sub all_docs {
    my ($self, $args) = @_;
    return $self->agent->get($self->uri_for('_all_docs', $args));
}

sub open_doc {
    my ($self, $id, $args) = @_;
    return $self->agent->get($self->uri_for($id, $args));
}

sub save_doc {
    my ($self, $doc, $args) = @_;

    my $agent   = $self->agent;
    my $content = $doc->to_json;
    my $res     = $doc->has_id
        ? $agent->put($self->uri_for($doc->id), Content => $content)
        : $agent->post($self->uri, Content => $content);

    # merge
    if ($res->is_success) {
        my $content = $res->content;
        $doc->id($content->id)   if $content->id;
        $doc->rev($content->rev) if $content->rev;
    }

    return $res;
}

sub remove_doc {
    my ($self, $doc, $args) = @_;

    return unless $doc->has_id and $doc->has_rev;

    my $params = { rev => $doc->rev, %{ $args || {} } };
    return $self->agent->delete($self->uri_for($doc->id, $params));
}

sub bulk_docs {
    # TODO: implements
}

sub query {
    # TODO: implements
}

sub view {
    # TODO: implements
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

CouchDB::Object::Database - Interface to CouchDB database

=head1 SYNOPSIS

=head1 METHODS

=head2 new(name => $dbname, uri => $uri)

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
