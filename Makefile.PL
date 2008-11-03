use inc::Module::Install;
name 'CouchDB-Object';
all_from 'lib/CouchDB/Object.pm';

requires 'Moose';
requires 'MooseX::Singleton';
requires 'MooseX::Types::URI';
requires 'Data::Dump::Streamer';
requires 'Hash::AsObject';
requires 'Hash::Merge';
requires 'HTTP::Headers';
requires 'HTTP::Request';
requires 'JSON::XS';
requires 'List::MoreUtils';
requires 'LWP::UserAgent';
requires 'URI';
requires 'URI::Escape';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::use::ok';
test_requires 'String::Random';
test_requires 'URI';
author_tests 'xt';
use_test_base;

auto_include;
WriteAll;
