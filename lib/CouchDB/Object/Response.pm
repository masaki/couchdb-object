package CouchDB::Object::Response;

use Moose;
use MooseX::Types::URI qw(Uri);
use CouchDB::Object::Document;
use CouchDB::Object::JSON;

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
    is      => 'ro',
    isa     => Uri,
    default => sub { shift->http_response->request->uri->clone },
    lazy    => 1,
);

has 'content' => (
    is      => 'ro',
    isa     => 'HashRef',
    builder => 'parse_content',
    lazy    => 1,
);

no Moose;

our $VERSION = '0.01';

sub new_from_response {
    my ($class, $res) = @_;
    return $class->new(http_response => $res);
}

sub parse_content {
    my $self = shift;
    my $res = $self->http_response;
    return CouchDB::Object::JSON->decode( $res->content_type =~ /json/i ? $res->content : {} );
}

sub to_document {
    my $self = shift;

    my $content = $self->content;
    return unless exists $content->{_id} and exists $content->{_rev};
    return CouchDB::Object::Document->new_from_json($content);
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

L<CouchDB::Object::Document>

=cut
