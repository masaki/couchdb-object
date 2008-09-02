use strict;
use t::CouchDB;

my $couch = test_couch();

unless ($couch->ping) {
    plan skip_all => "Can't connect CouchDB server: " . test_server();
}
else {
    plan tests => 10;
}

my ($name, $db) = deploy_db();
END { $db->drop if $couch->ping }

# { "id": "doc id 4", "title": "doc 4", "foo": "bar" },
{
    my $res = $db->open_doc('doc id 4');
    ok $res->is_success; # 200
    my $doc = $res->to_document;
    is $doc->id => 'doc id 4';
    ok $doc->rev;
    is $doc->title => 'doc 4';
    is $doc->foo => 'bar';
}

# { "id": "doc id 3", "title": "doc 3", "tags": ["aaa", "bbb", "ccc"] },
{
    my $res = $db->open_doc('doc id 3');
    ok $res->is_success; # 200
    my $doc = $res->to_document;
    is $doc->id => 'doc id 3';
    ok $doc->rev;
    is $doc->title => 'doc 3';
    is_deeply $doc->tags => [qw(aaa bbb ccc)];
}
