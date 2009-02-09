package CouchDB::Object::Role::Client;

use Mouse::Role;

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
        require CouchDB::Object;
        require LWP::UserAgent;
        LWP::UserAgent->new(
            agent      => "CouchDB::Object/$CouchDB::Object::VERSION",
            parse_head => 0,
            env_proxy  => 1,
        );
    },
);

has 'coder' => (
    is      => 'rw',
    isa     => 'JSON',
    lazy    => 1,
    default => sub {
        require JSON;
        JSON->new->utf8(1);
    },
);

sub uri_for {
    my ($self, @args) = @_;

    my $params = (scalar @args and ref $args[$#args] eq 'HASH') ? pop @args : {};

    require URI::Escape;
    my $path = join '/', map { URI::Escape::uri_escape_utf8($_) } map { split m!/! } @args;

    my $uri = $self->uri->clone;
    $uri->path($uri->path . $path);
    $uri->query_form($params);
    $uri->canonical;
}

no Mouse::Role; 1;
