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
    isa      => 'Hash::AsObject',
    required => 1,
);

no Moose;

sub new_from_response {
    my ($class, $http_res) = @_;

    my $content;
    if ($http_res->content_type =~ /json/) {
        $content = JSON::XS->new->decode($http_res->content);
    }
    else {
        $content = {};
    }

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
        my @docs = @{ $self->content->{rows} };
        for my $doc (@docs) {
            my $id = $doc->{id};
            $doc = CouchDB::Object::Document->new_from_json($doc->{value});
            $doc->id($id) if $id;
        }
        return wantarray ? @docs : \@docs;
    }

    return;
}

__PACKAGE__->meta->make_immutable;

1;
