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

for (1..5) {
    my $id = "doc id $_";
    my $doc = $db->open_doc($id)->to_document;
    ok $db->remove_doc($doc)->is_success; # 200
    ok $db->open_doc($id)->is_error;      # 404
}
