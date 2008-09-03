package CouchDB::Object::Response;

use Moose;
use MooseX::Types::URI qw(Uri);
use Hash::AsObject;
use JSON::XS ();
use CouchDB::Object::Document;

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
    isa      => 'Object', # XXX
    required => 1,
);

no Moose;

our $VERSION = '0.01';

sub new_from_response {
    my ($class, $res) = @_;

    return $class->new(
        http_response => $res,
        uri           => $res->request->uri->clone,
        content       => $class->parse_content($res),
    );
}

sub parse_content {
    my ($class, $res) = @_;

    my $content = $res->content_type =~ /json/i ? JSON::XS->new->decode($res->content) : {};

    if (ref $content->{rows} eq 'ARRAY') { # _all_docs
        my @docs = grep { exists $_->{id} and exists $_->{value} } @{ $content->{rows} };
        for my $doc (@docs) {
            my $id = delete $doc->{id};
            $doc = CouchDB::Object::Document->new_from_json($doc->{value});
            $doc->id($id) if defined $id;
        }
        $content->{rows} = \@docs;
    }
    elsif (ref $content->{new_revs} eq 'ARRAY') { # _bulk_docs
        for my $doc (@{ $content->{new_revs} }) {
            $doc = CouchDB::Object::Document->new_from_json($doc);
        }
    }

    if (exists $content->{_id} and exists $content->{_rev}) {
        return CouchDB::Object::Document->new_from_json($content);
    }
    else {
        return Hash::AsObject->new($content);
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
