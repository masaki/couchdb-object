package CouchDB::Object::Role::UserAgent;

use Mouse::Role;
use HTTP::Request;
use LWP::UserAgent;
use CouchDB::Object; # for VERSION

{ # TODO: patch to lwp
    package LWP::UserAgent;
    use strict;
    use warnings;

    sub put {
        require HTTP::Request::Common;
        my ($self, @params) = @_;
        my @suff = $self->_process_colonic_headers(\@params, ref $params[1] ? 2 : 1);
        return $self->request( HTTP::Request::Common::PUT(@params), @suff );
    }

    sub delete {
        require HTTP::Request::Common;
        my ($self, @params) = @_;
        my @suff = $self->_process_colonic_headers(\@params, 1);
        return $self->request( HTTP::Request::Common::DELETE(@params), @suff );
    }
}

has 'ua' => (
    is      => 'rw',
    isa     => 'LWP::UserAgent',
    lazy    => 1,
    default => sub {
        LWP::UserAgent->new(
            agent      => "CouchDB::Object/$CouchDB::Object::VERSION",
            parse_head => 0,
            env_proxy  => 1,
        );
    },
);

# requires_attr 'uri';

sub http_get    { shift->http_request(GET    => @_) }
sub http_post   { shift->http_request(POST   => @_) }
sub http_put    { shift->http_request(PUT    => @_) }
sub http_delete { shift->http_request(DELETE => @_) }

sub http_request {
    my ($self, $method, $uri, $body) = @_;

    require HTTP::Request;
    my $req = HTTP::Request->new(uc $method, $uri, [ Accept => 'application/json' ]);

    if (defined $body and length $body > 0) {
        $req->header('Content-Type' => 'application/json');
        $req->content($body);
    }

    return $self->ua->request($req);
}

sub uri_for {
    my ($self, @args) = @_;
    return unless $self->can('uri'); # Mouse hasn't has_method

    my $params = (scalar @args and ref $args[$#args] eq 'HASH') ? pop @args : {};

    require URI::Escape;
    my $path = join '/', map { URI::Escape::uri_escape_utf8($_) } map { split m!/! } @args;

    my $uri = $self->uri->clone;
    $uri->path($uri->path . $path);
    $uri->query_form($params);
    $uri->canonical;
}

no Mouse::Role; 1;
