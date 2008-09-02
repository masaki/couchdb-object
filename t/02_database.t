use strict;
use t::CouchDB;

my $couch = test_couch();

unless ($couch->ping) {
    plan skip_all => "Can't connect CouchDB server: " . test_server();
}
else {
    plan tests => 7;
}

my $server = test_server();
my $name   = test_dbname();

my $uri = $server->clone;
$uri->path_segments($name, '');

my $db = CouchDB::Object::Database->new(name => $name, server => $server);

is $db->uri => $uri;

# create
ok $db->info->is_error;     # 404
ok $db->create->is_success; # 201
ok $db->info->is_success;   # 200
is $db->info->content->db_name => $name;

# drop
ok $db->drop->is_success; # 200
ok $db->info->is_error;   # 404
