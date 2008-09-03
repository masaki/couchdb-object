use inc::Module::Install;
name 'CouchDB-Object';
all_from 'lib/CouchDB/Object.pm';

requires 'Moose';
requires 'MooseX::Types::URI';
requires 'Data::Dump::Streamer';
requires 'Hash::AsObject';
requires 'Hash::Merge';
requires 'HTTP::Headers';
requires 'HTTP::Request';
requires 'JSON::XS';
requires 'LWP::UserAgent';
requires 'URI';
requires 'URI::Escape';

# install_script '';

test_requires 'Test::More';
test_requires 'JSON::XS';
test_requires 'String::Random';
test_requires 'String::TT';
test_requires 'URI';

use_test_base;
auto_include;
WriteAll;
