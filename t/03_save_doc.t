use strict;
use t::CouchDB;

my $couch = test_couch();

unless ($couch->ping) {
    plan skip_all => "Can't connect CouchDB server: " . test_server();
}
else {
    plan tests => 11;
}

my $db = $couch->db(test_dbname());
$db->create;
END { $db->drop if $couch->ping }

# create (POST)
my $post = CouchDB::Object::Document->new;
$post->title('post doc');
ok $db->save_doc($post)->is_success; # 201
ok $post->id;
ok $post->rev;
is $post->title => 'post doc';

# modify (PUT)
my $rev = $post->rev;
$post->title('post modify doc');
ok $db->save_doc($post)->is_success; # 200
isnt $post->rev => $rev;
is $post->title => 'post modify doc';

# create with id (PUT)
my $put = CouchDB::Object::Document->new;
$put->id('put doc id');
$put->title('put doc');
ok $db->save_doc($put)->is_success; # 201
is $put->id => 'put doc id';
ok $put->rev;
is $put->title => 'put doc';
