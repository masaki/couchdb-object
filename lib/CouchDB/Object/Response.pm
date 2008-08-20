package CouchDB::Object::Response;

use Moose;
use MooseX::Types::URI qw(Uri);
use Hash::AsObject;
use JSON::XS ();
use CouchDB::Object;
use CouchDB::Object::Document;
use CouchDB::Object::Documents;

has 'http_response' => (
    is       => 'ro',
    isa      => 'HTTP::Response',
    required => 1,
    handles  => [qw(
        code message status_line
        is_info is_success is_redirect is_error
        header headers
        content_type last_modified
    )],
);

has 'uri' => (
    is       => 'ro',
    isa      => Uri,
    coerce   => 1,
    required => 1,
);

has 'content' => (
    is       => 'ro',
    isa      => 'Hash::AsObject',
    required => 1,
);

no Moose;

our $VERSION = CouchDB::Object->VERSION;

sub new_from_response {
    my ($class, $res) = @_;

    my $content = {};
    $content = JSON::XS->new->decode($res->content) if $res->content_type =~ /json/i;

    return $class->new(
        http_response => $http_res,
        uri           => $http_res->request->uri,
        content       => Hash::AsObject->new($content),
    );
}

sub to_document {
    my $self = shift;

    if (exists $self->content->{_id}) {
        return CouchDB::Object::Document->new_from_json($self->content);
    }
    elsif (exists $self->content->{rows}) {
        return CouchDB::Object::Documents->new_from_json($self->content);
    }
    else {
        return;
    }
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

CouchDB::Object::Response - Represention of HTTP response from CouchDB

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CouchDB::Object::Document>, L<CouchDB::Object::Documents>

=cut
