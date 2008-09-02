use strict;
use t::CouchDB;

my $couch = test_couch();

unless ($couch->ping) {
    plan skip_all => "Can't connect CouchDB server: " . test_server();
}
else {
    plan tests => 24;
}

my ($name, $db) = deploy_db();
END { $db->drop if $couch->ping }

{
    my $res = $db->all_docs;
    ok $res->is_success;

    my $docs = $res->to_document;
    is $docs->total_docs => 5;
    is $docs->offset => 0;

    is $docs->count => 5;
    for my $doc ($docs->all) { # 2 x 5 = 10
        ok $doc->id;
        ok $doc->rev;
    }
}

{
    my $res = $db->all_docs({ count => 3 });
    ok $res->is_success;

    my $docs = $res->to_document;
    is $docs->total_docs => 5;
    is $docs->offset => 0;

    is $docs->count => 3;
    for my $doc ($docs->all) { # 2 x 3 = 6
        ok $doc->id;
        ok $doc->rev;
    }
}
