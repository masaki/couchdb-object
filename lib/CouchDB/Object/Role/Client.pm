package CouchDB::Object::Role::Client;

use Moose::Role;
use HTTP::Request;
use URI::Escape ();
use CouchDB::Object::Response;
use CouchDB::Object::UserAgent;

# requires_attr 'uri';

has 'agent' => (
    is      => 'rw',
    isa     => 'LWP::UserAgent',
    default => sub { CouchDB::Object::UserAgent->new },
    lazy    => 1,
);

no Moose::Role;

our $VERSION = '0.01';

sub uri_for {
    my ($self, @args) = @_;

    my $params = (scalar @args and ref $args[$#args] eq 'HASH') ? pop @args : {};
    my $args = join '/', map { URI::Escape::uri_escape_utf8($_) } @args;
    $args =~ s!^/!!;

    my $class = ref $self->uri;
    my $base = $self->uri->clone;
    $base =~ s{(?<!/)$}{/};

    my $uri = bless \($base . $args) => $class;
    $uri->query_form($params);
    $uri->canonical;
}

sub request {
    my $self = shift;

    my $req = HTTP::Request->new(@_);
    my $res = $self->agent->request($req);

    return CouchDB::Object::Response->new_from_response($res);
}

1;

#__PACKAGE__->meta->make_immutable;
