# -*- mode: perl -*-
use Test::Base;
use Test::Deep;
use String::Random ();
use CouchDB::Object;

unless ($ENV{TEST_COUCHDB}) {
    plan skip_all => '$ENV{TEST_COUCHDB} required for network testing';
}
else {
    plan tests => 22;
}

my $couch = CouchDB::Object->new(uri => $ENV{TEST_COUCHDB});
# relax with couchdb
ok $couch;
ok $couch->info;

my $dbname = String::Random->new->randregex("[a-z]{20}");
my $db = $couch->db($dbname);
END { $db->drop if defined $db }

# create database
ok $db;
ok !$db->info;  # 404
ok $db->create; # 201
ok $db->info;   # 200

# save document
my $doc = CouchDB::Object::Document->new;
$doc->content("foo");
ok $db->save_doc($doc); # 201
ok $doc->has_id;
ok $doc->has_rev;
is $doc->content => "foo";

# update document
$doc->content("bar");
{
    my $id  = $doc->id;
    my $rev = $doc->rev;
    ok $db->save_doc($doc); # 200
    is   $doc->id  => $id;
    isnt $doc->rev => $rev;
}

# open document
{
    my $open = $db->open_doc($doc->id);
    ok $open;
    is $open->id      => $doc->id;
    is $open->rev     => $doc->rev;
    is $open->content => $doc->content;
}

# remove document
ok $db->remove_doc($doc);    # 200
ok !$db->remove_doc($doc);   # 404
ok !$db->open_doc($doc->id); # 404

# drop database
ok $db->drop;   # 200
ok !$db->info;  # 404
