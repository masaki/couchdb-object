use strict;
use t::CouchDB;

my $server = server();
my $couch  = CouchDB::Object::Server->new(uri => $server);

plan skip_all => "Can't connect CouchDB server: $server" unless $couch->ping;
plan tests => 15 if $couch->ping;

my $dbname = random_name();
my $dburi  = $server . $dbname;

my $db = $couch->db($dbname);
$db->create;
END {
    $db->drop if $couch->ping;
}

# CRUD

# [C]
my $new_doc = CouchDB::Object::Document->new;
my $new_title = 'doc 1';
$new_doc->title($new_title);
ok !$new_doc->id;
ok !$new_doc->rev;
ok $db->save_doc($new_doc)->is_success; # 201
ok $new_doc->id;
ok $new_doc->rev;

my $new_id  = $new_doc->id;
my $new_rev = $new_doc->rev;

# [R]
my $res = $db->open_doc($new_id);
ok $res->is_success; # 200
my $open_doc = $res->to_document;
is $open_doc->id    => $new_id;
is $open_doc->rev   => $new_rev;
is $open_doc->title => $new_title;

# [U]
my $mod_title = 'modified title';
$open_doc->title($mod_title);
ok $db->save_doc($open_doc)->is_success; # 200
is $open_doc->id => $new_id;
isnt $open_doc->rev => $new_rev;
is $open_doc->title => $mod_title;

# [D]
ok $db->remove_doc($open_doc)->is_success; # 200
ok $db->open_doc($new_id)->is_error;     # 404

