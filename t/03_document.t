use strict;
use t::CouchDB;
use CouchDB::Object::Document;

my $couch = test_couch();

unless ($couch->ping) {
    plan skip_all => "Can't connect CouchDB server: " . test_server();
}
else {
    plan tests => 23;
}

my $db = $couch->db(test_dbname());
$db->create;
END { $db->drop if $couch->ping }

my $json = read_json('t/docs.json');
delete $json->[0]->{_id};

# create (POST)
my $doc1 = CouchDB::Object::Document->new_from_json($json->[0]);
is $doc1->content => 'test document 1';
is_deeply $doc1->tags => [qw(test document 1)];
ok $db->save_doc($doc1)->is_success; # 201
ok $doc1->has_id;
ok $doc1->has_rev;

# modify (PUT)
my $rev = $doc1->rev;
$doc1->author('baz');
ok $db->save_doc($doc1)->is_success; # 200
isnt $doc1->rev => $rev;
is $doc1->author => 'baz';

# create with id (PUT)
my $doc2 = CouchDB::Object::Document->new_from_json($json->[1]);
is $doc2->id => 'test-document-2';
is $doc2->content => 'test document 2';
is_deeply $doc2->tags => [qw(test document 2)];
ok $db->save_doc($doc2)->is_success; # 201
ok $doc2->has_rev;

# open (GET)
ok $db->open_doc('not-exist-id')->is_error; # 404

my $res = $db->open_doc('test-document-2');
ok $res->is_success; # 200

my $doc3 = $res->to_document;
isa_ok $doc3 => 'CouchDB::Object::Document';
is $doc3->id => $doc2->id;
ok $doc3->has_rev;
is $doc3->content => $doc2->content;
is_deeply $doc3->tags => $doc2->tags;

# remove (DELETE)
ok $db->remove_doc($doc1)->is_success; # 200
ok $db->remove_doc($doc2)->is_success; # 200
ok $db->open_doc($doc3->id)->is_error; # 404
