use strict;
use t::CouchDB;
use String::TT qw(strip);
use CouchDB::Object::Document;

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
    my $res = $db->query(strip q[
        function(doc) {
            if (doc.title == "doc 3") {
                emit(null, doc);
            }
        }
    ]);
    ok $res->is_success;

    my $docs = $res->content;
    is $docs->{total_rows} => 1;
    is $docs->{offset} => 0;

    for my $doc (@{ $docs->{rows} }) { # 1 x 5 = 5
        $doc = CouchDB::Object::Document->new_from_json($doc->{value});
        isa_ok $doc => 'CouchDB::Object::Document';
        is $doc->id => 'doc id 3';
        ok $doc->has_rev;
        is $doc->title => 'doc 3';
        is_deeply $doc->tags => [qw(aaa bbb ccc)];
    }
}
