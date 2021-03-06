# -*- mode: perl -*-
use Test::Base;
use Test::Deep;
use String::Random ();
use CouchDB::Object;
use CouchDB::Object::Document;

plan skip_all => '$ENV{TEST_COUCHDB} required for network testing' unless $ENV{TEST_COUCHDB};
plan tests => 108;

my $couch = CouchDB::Object->new(uri => $ENV{TEST_COUCHDB});
my $dbname = String::Random->new->randregex("[a-z][0-9a-z]{19}");
my $db = $couch->db($dbname);
$db->create;

# create with bulk_docs
my @docs = map { CouchDB::Object::Document->new(num => $_) } (0..14);
ok $db->bulk_docs(\@docs), 'ok create bulk_docs';
for my $doc (@docs) {
    ok $doc->has_id, 'ok has id created document';
    ok $doc->has_rev, 'ok has rev created document';
    like $doc->num => qr/^\d+$/, 'ok has and valid num';
}

# update and delete with bulk_docs
my $i = 0;
for my $doc (@docs) {
    $i++ > 10 ? $doc->deleted(1) : $doc->num2($doc->num * 2);
}
ok $db->bulk_docs(\@docs), 'ok update and delete bulk_docs';

# all_docs
my $all_docs = $db->all_docs;
is $all_docs->count => 11, 'ok count all_docs';
is $all_docs->total_rows => 11, 'ok total_rows all_docs';
while (my $doc = $all_docs->next) {
    ok $doc->has_id, 'ok has id in all_docs';
    ok $doc->has_rev, 'ok has rev in all_docs';
}

SKIP: {
    my ($major, $minor, $teeny) = split /\./, $couch->version;
    skip 'required over 0.9.0', 37
        if $major < 1 and $minor < 9;

    # all_docs with contents
    my $all_include_docs = $db->all_docs({ include_docs => "true" });
    is $all_include_docs->count => 11, 'ok count all_docs with include_docs';
    is $all_include_docs->total_rows => 11, 'ok total_rows all_docs with include_docs';
    while (my $doc = $all_include_docs->next) {
        ok $doc->has_id, 'ok has id in all_docs with include_docs';
        ok $doc->has_rev, 'ok has rev in all_docs with include_docs';
        is $doc->num2 => ($doc->num * 2), 'ok updated num';
    }

    # all_docs with "limit"
    my $limited_docs = $db->all_docs({ limit => 5 });
    is $limited_docs->count => 5, 'ok count all_docs limit';
    is $limited_docs->total_rows => 11, 'ok total_rows all_docs limit';
}

# teadown
END { $db->drop if defined $db }
