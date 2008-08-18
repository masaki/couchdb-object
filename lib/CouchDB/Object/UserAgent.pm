package CouchDB::Object::UserAgent;

use Moose;

extends 'LWP::UserAgent';

no Moose;
use HTTP::Request::Common 5.814 qw(PUT DELETE);
use CouchDB::Object;
use CouchDB::Object::Response;

our $VERSION = CouchDB::Object->VERSION;

sub BUILD {
    my $self = shift;

    $self->agent("CouchDB::Object/$CouchDB::Object::VERSION");
    $self->parse_head(0);
    $self->env_proxy;
}

sub request {
    my ($self, $req) = @_;

    $req->header(Accept => 'application/json');
    $req->header(Content_Type => 'application/json') if $req->content;

    my $res = $self->SUPER::request($req);
    return CouchDB::Object::Response->new_from_response($res);
}

sub put {
    my ($self, @params) = @_;
    my @suff = $self->_process_colonic_headers(\@params, ref $params[1] ? 2 : 1);
    return $self->request(PUT(@params), @suff);
}

sub delete {
    my ($self, @params) = @_;
    my @suff = $self->_process_colonic_headers(\@params, 1);
    return $self->request(DELETE(@params), @suff);
}

__PACKAGE__->meta->make_immutable;

1;
