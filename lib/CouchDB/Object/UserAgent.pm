package CouchDB::Object::UserAgent;

use Moose;
use CouchDB::Object;

extends 'LWP::UserAgent';

no Moose;

our $VERSION = '0.01';

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

    # TODO: super()
    return $self->SUPER::request($req);
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

CouchDB::Object::UserAgent

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CouchDB::Object::Response>

=cut
