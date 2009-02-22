package CouchDB::Object::Role::UriFor;

use Mouse::Role;
use URI::Escape qw(uri_escape_utf8);
use namespace::clean -except => ['meta'];

# requires_attr 'uri';

sub uri_for {
    my ($self, @args) = @_;
    return unless $self->meta->has_attribute('uri');

    my $params = (scalar @args and ref $args[$#args] eq 'HASH') ? pop @args : {};

    my $path = join '/', map { uri_escape_utf8($_) } map { split m!/! } @args;

    my $uri = $self->uri->clone;
    $uri->path($uri->path . $path);
    $uri->query_form($params);
    $uri->canonical;
}

no Mouse::Role; 1;
