package CouchDB::Object::Utils;

use strict;
use warnings;
use Exporter qw(import);
use Class::Inspector;
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

=head1 NAME

CouchDB::Object::Utils

=head1 METHODS

=head2 uri_for

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
