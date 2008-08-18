package CouchDB::Object::Server;

use Moose;
use MooseX::Types::URI qw(Uri);
use URI;
use CouchDB::Object::UserAgent;

has 'uri' => (
    is       => 'ro',
    isa      => Uri,
    coerce   => 1,
    required => 1,
    default  => sub { URI->new('http://localhost:5984/') },
);

has 'agent' => (
    is       => 'ro',
    isa      => 'CouchDB::Object::UserAgent',
    required => 1,
    default  => sub { CouchDB::Object::UserAgent->new },
);

no Moose;
use CouchDB::Object;
use CouchDB::Object::Database;
use CouchDB::Object::Utils qw(uri_for);

our $VERSION = CouchDB::Object->VERSION;

sub BUILD {
    my ($self, $args) = @_;
    $self->uri->path('/');
    $self->uri->$_(undef) for qw(query fragment);
}

sub db {
    my ($self, $name) = @_;
    return CouchDB::Object::Database->new(
        name  => $name,
        uri   => $self->uri_for($name),
        agent => $self->agent,
    );
}

sub all_dbs {
    my ($self, $args) = @_;
    my $res = $self->agent->get($self->uri_for('_all_dbs'));
    my @dbs = $self->ping ? map { $self->db($_) } @{ $res->parsed_content } : ();
    return wantarray ? @dbs : \@dbs;
}

sub info {
    my $self = shift;
    return $self->agent->get($self->uri);
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

CouchDB::Object::Server - Interface to CouchDB server

=head1 SYNOPSIS

  use CouchDB::Object::Server;

  my $couch = CouchDB::Object::Server->new(uri => 'http://localhost:5984');

  if ($couch->ping) {
      print "connect CouchDB";

      my $db = $couch->db('dbname');
      my @dbs = $couch->all_dbs;
  }

=head1 METHODS

=head2 new(uri => $uri)

Returns the CouchDB server object.

=head2 uri

Returns the CouchDB server uri as <URI> object.

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
