# -*- mode: perl -*-
use Test::Base;
use Test::Deep;
use String::Random ();
use CouchDB::Object;
use CouchDB::Object::Document;

unless ($ENV{TEST_COUCHDB}) {
    plan skip_all => '$ENV{TEST_COUCHDB} required for network testing';
}
else {
    plan tests => 53;
}

my $couch = CouchDB::Object->new(uri => $ENV{TEST_COUCHDB});

my $dbname = String::Random->new->randregex("[a-z]{20}");
my $db = $couch->db($dbname);
$db->create;
END { $db->drop if defined $db }

{ # bulk_docs (21 tests)
    my @docs = map { CouchDB::Object::Document->new({ num => $_ }) } (1..10);

    ok $db->bulk_docs(\@docs);
    for my $doc (@docs) { # 10 times x 2 tests = 20
        ok $doc->has_id;
        ok $doc->has_rev;
    }
}

{ # all_docs (21 tests)
    my $docs = $db->all_docs;
    is $docs->count => 10;

    while (my $doc = $docs->next) { # 10 times x 2 tests = 20
        ok $doc->has_id;
        ok $doc->has_rev;
    }
}

{ # all_docs with counts (11 tests)
    my $docs = $db->all_docs({ limit => 5 });
    is $docs->count => 5;

    while (my $doc = $docs->next) { # 5 times x 2 tests = 10
        ok $doc->has_id;
        ok $doc->has_rev;
    }
}
