package CouchDB::Object::Role::UriFor;

use Mouse::Role;
use URI::Escape ();

sub uri_for {
    my ($self, @args) = @_;
    return unless $self->can('uri');

    my $uri = $self->uri->clone;

    my $params = (scalar @args and ref $args[$#args] eq 'HASH') ? pop @args : {};
    $uri->query_form($params);

    my @path = ($uri->path_segments, map { split m!/! } @args);
    my $path = join '/', map { URI::Escape::uri_escape_utf8($_) } @path;
    $uri->path($path);

    return $uri->canonical;
}

no Mouse::Role; 1;
