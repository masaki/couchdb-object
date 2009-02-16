package CouchDB::Object;

use 5.008001;
use Mouse;
use MouseX::Types::URI;
use CouchDB::Object::Database;

with qw(
    CouchDB::Object::Role::UserAgent
    CouchDB::Object::Role::Serializer
);

has 'uri' => (
    is      => 'rw',
    isa     => 'URI',
    coerce  => 1,
    lazy    => 1,
    default => sub {
        require URI;
        URI->new('http://localhost:5984/');
    },
);

our $VERSION = '0.01';

sub info {
    my $self = shift;

    my $res = $self->ua->get($self->uri, Accept => 'application/json');
    return unless $res->is_success;
    return $self->deserialize($res->decoded_content);
}

sub db {
    my ($self, $name) = @_;
    return CouchDB::Object::Database->new(
        name     => $name,
        base_uri => $self->uri->clone,
        ua       => $self->ua,
    );
}

sub all_dbs {
    my ($self, $args) = @_;

    my $res = $self->ua->get($self->uri_for('_all_dbs'), Accept => 'application/json');
    return unless $res->is_success;
    return map { $self->db($_) } @{ $self->deserialize($res->decoded_content) };
}

sub replicate {
    # TODO: implements
}

no Mouse; __PACKAGE__->meta->make_immutable; 1;

=head1 NAME

CouchDB::Object - Yet another CouchDB client

=head1 SYNOPSIS

  use CouchDB::Object;

  my $couch = CouchDB::Object->new(host => 'localhost', port => 5984);

  if ($couch->ping) {
      print "connect CouchDB";

      my $db = $couch->db('dbname');
      my @dbs = $couch->all_dbs;
  }

=head1 METHODS

=head2 new(host => $host, port => $port [, scheme => $scheme ])

Returns the CouchDB server object.

=head2 ping

Returns true if a connection can be made to the server, false otherwise.

=head2 db($dbname)

Returns the L<CouchDB::Object::Database> object of that name.

=head2 all_dbs

Returns L<CouchDB::Object::Database> objects that the server knows of.

=head2 info

Returns the L<CouchDB::Object::Response> object for server.

=head2 replicate

Not implemented yet.

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CouchDB::Object::Database>, L<CouchDB::Object::Response>

=cut
