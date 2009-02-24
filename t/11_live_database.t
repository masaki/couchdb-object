# -*- mode: perl -*-
use Test::Base;
use Test::Data::Scalar;
use String::Random ();
use CouchDB::Object;

plan skip_all => '$ENV{TEST_COUCHDB} required for network testing' unless $ENV{TEST_COUCHDB};
plan tests => 13;

my $couch = CouchDB::Object->new(uri => $ENV{TEST_COUCHDB});
my $dbname = String::Random->new->randregex("[a-z][0-9a-z]{19}");
my $db = $couch->db($dbname);

ok !$db->info, '1st, not exists database';

ok $db->create, "create database $dbname";

my $info = $db->info;
ok $info, 'ok info';
is $info->db_name => $dbname, 'ok db_name';
is $info->doc_count => 0, 'ok doc_count';
is $info->doc_del_count => 0, 'ok doc_del_count';
is $info->update_seq => 0, 'ok update_seq';
is $info->compact_running => 0, 'ok compact_running';
ok $info->disk_size > 0, 'ok disk_size';
SKIP: {
    my ($major, $minor, $teeny) = split /\./, $couch->version;
    skip 'required over 0.9.0', 2
        if $major < 1 and $minor < 9;

    is $info->purge_seq => 0, 'ok purge_seq';
    ok $info->instance_start_time > 0, 'ok instance_start_time';
};

ok $db->drop, 'drop database';

ok !$db->info, 'finnaly, not exists database again';

# teadown
END { $db->drop if defined $db }
