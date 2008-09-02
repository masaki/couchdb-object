use strict;
use t::CouchDB;
use String::TT qw(strip tt);

my $couch = test_couch();

unless ($couch->ping) {
    plan skip_all => "Can't connect CouchDB server: " . test_server();
}
else {
    plan tests => 8;
}

my ($name, $db) = deploy_db();
END { $db->drop if $couch->ping }

{ # doc 3 only
    my $res = $db->query(strip tt q[
        function(doc) {
            if (doc.title == "doc 3") {
                emit(null, doc);
            }
        }
    ]);
    ok $res->is_success;

    my $docs = $res->to_document;
    is $docs->total_docs => 1;
    is $docs->offset => 0;
    is $docs->count => 1;

    for my $doc ($docs->all) { # 1 x 4 = 4
        is $doc->id => 'doc id 3';
        ok $doc->rev;
        is $doc->title => 'doc 3';
        is_deeply $doc->tags => [qw(aaa bbb ccc)];
    }
}
