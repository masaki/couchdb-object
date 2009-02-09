# -*- mode: perl -*-
use Test::Base -Base;
use Test::Deep;
use t::CouchDB;
use CouchDB::Object;
use CouchDB::Object::Document;

unless ($ENV{TEST_COUCHDB}) {
    plan skip_all => '$ENV{TEST_COUCHDB} required for network testing';
}
else {
    plan tests => 24;
}

my $db = test_db();
END { $db->drop if $db } # finalize

# create (POST)
my $doc = CouchDB::Object::Document->new;
$doc->content('content 1');
$doc->tags(['tag1', 'tag2']);
ok $db->save_doc($doc); # 201
ok $doc->has_id;
ok $doc->has_rev;
is $doc->content => 'content 1';
cmp_deeply $doc->tags => ['tag1', 'tag2'];

# create with id (PUT)
my $doc_with_id = CouchDB::Object::Document->new;
$doc_with_id->id('test doc_with_id');
$doc_with_id->content('content 2');
ok $db->save_doc($doc_with_id); # 201
ok $doc_with_id->has_id;
ok $doc_with_id->has_rev;

# modify (PUT)
my $id = $doc->id;
my $rev = $doc->rev;
$doc->title('foo');
$doc->content('content 1 fixed');
ok $db->save_doc($doc); # 200
is $doc->id => $id;
isnt $doc->rev => $rev;
is $doc->title => 'foo';
is $doc->content => 'content 1 fixed';
cmp_deeply $doc->tags => ['tag1', 'tag2'];

# open (GET)
ok !$db->open_doc('user-specified-not-exist-couchdb-document-id'); # 404

my $open_doc = $db->open_doc($id);
ok $open_doc;
is $open_doc->id => $id;
is $open_doc->rev => $doc->rev;
is $open_doc->content => $doc->content;
cmp_deeply $open_doc->tags => $doc->tags;

# remove (DELETE)
ok $db->remove_doc($doc);         # 200
ok $db->remove_doc($doc_with_id); # 200
ok !$db->remove_doc($doc);        # 404
ok $db->open_doc($doc->id);       # 404
