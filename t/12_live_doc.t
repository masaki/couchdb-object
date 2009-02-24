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

# createdocument
my $doc = CouchDB::Object::Document->new;
$doc->content("foo");
ok $db->save_doc($doc); # 201
ok $doc->has_id;
ok $doc->has_rev;
is $doc->content => "foo";

# update document
$doc->content("bar");
my $old_id  = $doc->id;
my $old_rev = $doc->rev;
ok $db->save_doc($doc); # 200
is   $doc->id  => $old_id;
isnt $doc->rev => $old_rev;

# open document
my $open_doc = $db->open_doc($doc->id);
ok $open_doc;
is $open_doc->id      => $doc->id;
is $open_doc->rev     => $doc->rev;
is $open_doc->content => $doc->content;

# remove document
ok $db->remove_doc($doc);    # 200
ok !$db->remove_doc($doc);   # 404
ok !$db->open_doc($doc->id); # 404

# teadown
END { $db->drop if defined $db }
