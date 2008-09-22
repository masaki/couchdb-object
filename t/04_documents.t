use strict;
use t::CouchDB;
use CouchDB::Object::Document;

my $couch = test_couch();

unless ($couch->ping) {
    plan skip_all => "Can't connect CouchDB server: " . test_server();
}
else {
    plan tests => 316;
}

my $db = $couch->db(test_dbname());
$db->create;
END { $db->drop if $couch->ping }

# /{dbname}/_bulk_docs (bulk_docs)
{ # 32
    my $json = read_json('t/docs.json');
    my @docs = map { CouchDB::Object::Document->new_from_json($_) } @$json;
    my $res = $db->bulk_docs(\@docs);
    ok $res->is_success;
    ok $res->content->{ok};

    for my $doc (@docs) { # 1 x 30 = 30
        ok $doc->has_rev;
    }
}

# /{dbname}/_all_docs (all_docs)
{ # 93
    my $res = $db->all_docs;
    ok $res->is_success;
    is $res->content->{total_rows} => 30;
    is $res->content->{offset} => 0;

    my @docs = $res->to_document;
    for my $doc (@docs) { # 3 x 30 = 90
        isa_ok $doc => 'CouchDB::Object::Document';
        like $doc->id => qr/test\-document\-/;
        ok $doc->has_rev;
    }
}

{ # 4
    my $res = $db->all_docs({ count => 12 });
    ok $res->is_success;
    is $res->content->{total_rows} => 30;
    is $res->content->{offset} => 0;

    my @docs = $res->to_document;
    is scalar(@docs) => 12;
}

# /{dbname}/_temp_view (query)
{ # 183
    my $res = $db->query('function(doc) { emit(null, doc) }');
    ok $res->is_success;
    is $res->content->{total_rows} => 30;
    is $res->content->{offset} => 0;

    my @docs = $res->to_document;
    for my $doc (@docs) { # 6 x 30 = 180
        isa_ok $doc => 'CouchDB::Object::Document';
        like $doc->id => qr/test\-document\-/;
        ok $doc->has_rev;
        ok $doc->author;
        like $doc->content => qr/test document /;
        is scalar(@{ $doc->tags }) => 3;
    }
}

{ # 4
    my $res = $db->query('function(doc) { emit(doc.author, doc) }', '', '', { key => '"foo"' });
    ok $res->is_success;
    is $res->content->{total_rows} => 30;
    is $res->content->{offset} => 15;

    my @docs = $res->to_document;
    is scalar(@docs) => 15;
}
