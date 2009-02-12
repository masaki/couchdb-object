use inc::Module::Install;
name 'CouchDB-Object';
all_from 'lib/CouchDB/Object.pm';

requires 'Mouse' => '0.16';
requires 'MouseX::Types::URI' => '0.02';
requires 'URI';

# Database
requires 'Data::Dump::Streamer';
requires 'HTTP::Headers';
requires 'List::MoreUtils';
# Document
requires 'Data::OpenStruct::Deep';

# Role::UserAgent
requires 'HTTP::Request::Common';
requires 'LWP::UserAgent';
requires 'URI::Escape';
# Role::Serializer
requires 'JSON' => '2.07';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::use::ok';
test_requires 'String::Random';
test_requires 'URI';
author_tests 'xt';
use_test_base;

auto_include;
WriteAll;
