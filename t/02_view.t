# -*- mode: perl -*-
use Test::Base;
use Test::Deep;
use CouchDB::Object::View;
use CouchDB::Object::DesignDocument;

plan tests => 7 * 2;

my @view = (
    CouchDB::Object::View->new(name => 'foo', map => 'function(doc) { emit(null, doc) }'),
    CouchDB::Object::View->new(
        name   => 'bar',
        map    => 'function(doc) { emit(doc.bar, doc) }',
        reduce => 'function(keys, values) { return sum(values) }',
    ),
);

my $tester = sub {
    my $doc = shift;

    ok $doc->has_id, 'has id';
    is $doc->id => "foobar", 'not start "_design"';

    is scalar(my @views = $doc->views) => 2;
    ok $doc->view('foo'), 'has "foo" view';
    ok $doc->view('bar'), 'has "bar" view';
    ok !$doc->view('baz'), 'not has "baz" view';

    cmp_deeply $doc->to_hash => {
        _id      => "_design/foobar",
        language => "javascript",
        views    => {
            foo => {
                map => "function(doc) { emit(null, doc) }",
            },
            bar => {
                map    => "function(doc) { emit(doc.bar, doc) }",
                reduce => "function(keys, values) { return sum(values) }",
            },
        },
    }, 'to_hash correctly';
};

{ # read from hashref
    my $doc = CouchDB::Object::DesignDocument->new({
        _id      => "_design/foobar",
        language => "javascript",
        views    => {
            foo => {
                map => "function(doc) { emit(null, doc) }",
            },
            bar => {
                map    => "function(doc) { emit(doc.bar, doc) }",
                reduce => "function(keys, values) { return sum(values) }",
            },
        },
    });

    $tester->($doc);
}

{ # empty
    my $doc = CouchDB::Object::DesignDocument->new;
    $doc->id("foobar");
    $doc->add_view($_) for @view;

    $tester->($doc);
}
