use inc::Module::Install;
name 'CouchDB-Object';
all_from 'lib/CouchDB/Object.pm';

requires 'Mouse' => '0.15';
requires 'MouseX::Types::URI' => '0.02';

requires 'Data::Dump::Streamer';
requires 'Hash::AsObject';
requires 'Hash::Merge';
requires 'HTTP::Headers';

requires 'HTTP::Request::Common';
requires 'LWP::UserAgent';
requires 'URI';
requires 'URI::Escape';
requires 'JSON' => '2.07';

requires 'List::MoreUtils';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::use::ok';
test_requires 'String::Random';
test_requires 'URI';
author_tests 'xt';
use_test_base;

auto_include;
WriteAll;
