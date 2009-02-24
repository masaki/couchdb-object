# -*- mode: perl -*-
use Test::Base;
use String::Random ();
use CouchDB::Object;
use CouchDB::Object::Document;

plan skip_all => '$ENV{TEST_COUCHDB} required for network testing' unless $ENV{TEST_COUCHDB};
plan 'no_plan';

my $couch = CouchDB::Object->new(uri => $ENV{TEST_COUCHDB});
my $dbname = String::Random->new->randregex("[a-z][0-9a-z]{19}");
my $db = $couch->db($dbname);
$db->create;

# create document
my $doc = CouchDB::Object::Document->new;
$doc->content("foo");
ok $db->save_doc($doc), 'create document';
ok $doc->has_id, 'has id';
ok $doc->has_rev, 'has rev';
is $doc->content => "foo", 'ok content';

# update document
$doc->content("bar");
my $id = $doc->id;
my $rev = $doc->rev;
ok $db->save_doc($doc), 'update document';
is $doc->id => $id, 'ok update id';
isnt $doc->rev => $rev, 'ok update rev';
is $doc->content => "bar", 'ok update content';

# open document
my $open_doc = $db->open_doc($id);
ok $open_doc, 'open document';
is $open_doc->id => $id, 'ok open id';
is $open_doc->rev => $doc->rev, 'ok open rev';
is $open_doc->content => $doc->content, 'ok open content';

# remove document
ok $db->remove_doc($doc), 'remove document';
ok !$db->remove_doc($doc), 'fail remove document if not exists';
ok !$db->open_doc($id), 'fail open document if not exists';

# teadown
END { $db->drop if defined $db }
