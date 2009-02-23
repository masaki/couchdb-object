package CouchDB::Object::Role::UserAgent;

use Mouse::Role;
use HTTP::Request;
use LWP::UserAgent;
use CouchDB::Object; # for VERSION

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

sub http_get    { shift->http_request(GET    => @_) }
sub http_post   { shift->http_request(POST   => @_) }
sub http_put    { shift->http_request(PUT    => @_) }
sub http_delete { shift->http_request(DELETE => @_) }

sub http_request {
    my ($self, $method, $uri, %args) = @_;

    my $req = HTTP::Request->new(uc $method, $uri);

    if (exists $args{Content}) {
        my $body = delete $args{Content};
        $req->header('Content-Type' => 'application/json');
        $req->header('Content-Length' => length $body);
        $req->content($body);
    }

    $req->header('Accept' => 'application/json');
    while (my ($name, $value) = each %args) {
        $req->header($name => $value);
    }

    return $self->ua->request($req);
}

no Mouse::Role; 1;
