use strict;
use t::CouchDB;

my $couch = test_couch();

unless ($couch->ping) {
    plan skip_all => "Can't connect CouchDB server: " . test_server();
}
else {
    plan tests => 22;
}

my ($name, $db) = deploy_db();
END { $db->drop if $couch->ping }

{
    my $res = $db->all_docs;
    ok $res->is_success;

    my $docs = $res->content;
    is $docs->{total_rows} => 5;
    is $docs->{offset} => 0;

    for my $doc (@{ $docs->{rows} }) { # 2 x 5 = 10
        ok $doc->{id};
        ok $doc->{value}->{rev};
    }
}

{
    my $res = $db->all_docs({ count => 3 });
    ok $res->is_success;

    my $docs = $res->content;
    is $docs->{total_rows} => 5;
    is $docs->{offset} => 0;

    for my $doc (@{ $docs->{rows} }) { # 2 x 3 = 6
        ok $doc->{id};
        ok $doc->{value}->{rev};
    }
}
