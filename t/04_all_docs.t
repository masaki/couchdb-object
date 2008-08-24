use strict;
use t::CouchDB;

my $server = server();
my $couch  = CouchDB::Object::Server->new(uri => $server);

plan skip_all => "Can't connect CouchDB server: $server" unless $couch->ping;
plan tests => 22 if $couch->ping;

my $dbname = random_name();
my $dburi  = $server . $dbname;

my $db = $couch->db($dbname);
$db->create;
END {
    $db->drop if $couch->ping;
}

my @docs = ();
for (1..5) {
    my $doc = CouchDB::Object::Document->new;
    $doc->id(sprintf '%03d', $_);
    $db->save_doc($doc);
    push @docs, $doc;
}

my $all_docs = $db->all_docs->to_document;
is $all_docs->total_docs => 5;
is $all_docs->count => 5;
is $all_docs->offset => 0;
my @all_docs = $all_docs->docs;
for (0..4) {
    is $all_docs[$_]->id,  $docs[$_]->id;
    is $all_docs[$_]->rev, $docs[$_]->rev;
}

my $counted_docs = $db->all_docs({ count => 3 })->to_document;
is $counted_docs->total_docs => 5;
is $counted_docs->count => 3;
is $counted_docs->offset => 0;
my @counted_docs = $counted_docs->docs;
for (0..2) {
    is $counted_docs[$_]->id,  $docs[$_]->id;
    is $counted_docs[$_]->rev, $docs[$_]->rev;
}
