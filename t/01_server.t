use strict;
use t::CouchDB;

my $server = server();
my $couch  = CouchDB::Object::Server->new(uri => $server);

plan skip_all => "Can't connect CouchDB server: $server" unless $couch->ping;
plan tests => 3 if $couch->ping;

# server info
is $couch->uri => $server;
ok $couch->info->is_success;

# replicate
TODO: {
    local $TODO = 'replicate(): not implemented yet';
    ok $couch->replicate;
};
