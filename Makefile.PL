use inc::Module::Install;
name 'CouchDB-Object';
all_from 'lib/CouchDB/Object.pm';

requires 'Moose';
requires 'MooseX::AttributeHelpers';
requires 'MooseX::Types::URI';
requires 'Class::Inspector';
requires 'Exporter';
requires 'Hash::AsObject';
requires 'Hash::Merge';
requires 'HTTP::Request::Common' => 5.814; # for DELETE
requires 'HTTP::Response';
requires 'JSON::XS';
requires 'LWP::UserAgent';
requires 'URI';
requires 'URI::Escape';

# install_script '';

test_requires 'Test::More';
test_requires 'String::Random';
use_test_base;
auto_include;
WriteAll;
