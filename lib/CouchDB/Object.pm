package CouchDB::Object;

use Moose;
use URI;
use CouchDB::Object::Database;

with 'CouchDB::Object::Role::Client';

has 'scheme' => (is => 'rw', isa => 'Str', default => sub { 'http' });
has 'host'   => (is => 'rw', isa => 'Str', default => sub { 'localhost' });
has 'port'   => (is => 'rw', isa => 'Num', default => sub { 5984 });

no Moose;

our $VERSION = '0.01';

sub uri {
    my $self = shift;
    return URI->new(sprintf '%s://%s:%d/', $self->scheme, $self->host, $self->port);
}

sub db {
    my ($self, $name) = @_;
    return CouchDB::Object::Database->new(
        name   => $name,
        server => $self->uri,
        agent  => $self->agent,
    );
}

sub all_dbs {
    my ($self, $args) = @_;

    my $res = $self->request(GET => $self->uri_for('_all_dbs'));
    return $self->ping ? map { $self->db($_) } @{ $res->content } : ();
}

sub info {
    my $self = shift;
    return $self->request(GET => $self->uri);
}

sub ping {
    my $self = shift;
    return eval { $self->info->is_success };
}

sub replicate {
    # TODO: implements
}

__PACKAGE__->meta->make_immutable;

1;

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
