package CouchDB::Object::JSON;

use MooseX::Singleton;
use JSON::XS ();

has 'coder' => (
    is      => 'ro',
    isa     => 'JSON::XS',
    default => sub { JSON::XS->new },
    lazy    => 1,
    handles => [qw(encode decode)],
);

our $VERSION = '0.01';

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

CouchDB::Object::JSON

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<MooseX::Singleton>, L<JSON::XS>

=cut
