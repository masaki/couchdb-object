use inc::Module::Install;
name 'CouchDB-Object';
all_from 'lib/CouchDB/Object.pm';

requires 'Mouse' => '0.16';
requires 'MouseX::Types::URI' => '0.02';
requires 'URI';

# Role::UserAgent
requires 'HTTP::Request::Common';
requires 'LWP::UserAgent';
requires 'URI::Escape';
# Role::Serializer
requires 'JSON' => '2.07';

# Database
requires 'List::MoreUtils';
# Document
requires 'Data::OpenStruct::Deep';
# Iterator
requires 'Array::Iterator';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'ok';
test_requires 'Test::Deep';
test_requires 'String::Random';
author_tests 'xt';
use_test_base;

auto_include;
WriteAll;
