use strict;
use t::CouchDB;

my $server = server();
my $couch  = CouchDB::Object::Server->new(uri => $server);

plan skip_all => "Can't connect CouchDB server: $server" unless $couch->ping;
plan tests => 7 if $couch->ping;

my $name = random_name();
my $uri  = $server . $name;
my $db   = $couch->db($name);

# info
is $db->name => $name;
is $db->uri  => $uri;

# create
ok $db->info->is_error;     # 404
ok $db->create->is_success; # 201
ok $db->info->is_success;   # 200

# drop
ok $db->drop->is_success; # 200
ok $db->info->is_error;   # 404
