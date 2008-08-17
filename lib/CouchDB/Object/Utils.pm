package CouchDB::Object::Utils;

use strict;
use warnings;
use Class::Inspector;
use Exporter qw(import);
use URI::Escape qw(uri_escape_utf8);
use CouchDB::Object;

our $VERSION = CouchDB::Object->VERSION;
our @EXPORT_OK = @{ Class::Inspector->functions(__PACKAGE__) };

sub uri_for {
    my ($self, @args) = @_;
    return unless $self->can('uri');

    my $params = (scalar @args and ref $args[$#args] eq 'HASH') ? pop @args : {};
    my $args = join '/', map { uri_escape_utf8($_) } @args;
    $args =~ s!^/!!;

    my $class = ref $self->uri;
    my $base = $self->uri->clone;
    $base =~ s{(?<!/)$}{/};

    my $uri = bless \($base . $args) => $class;
    $uri->query_form($params);
    $uri->canonical;
}

1;
