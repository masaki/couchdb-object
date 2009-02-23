# -*- mode: perl -*-
use Test::Base;
use Test::Deep;
use CouchDB::Object::Document;

plan tests => 8 * 3;

my $tester = sub {
    my $doc = shift;

    ok $doc->has_id;
    is $doc->id => "foo", 'id ok';

    ok $doc->has_rev;
    is $doc->rev => "foo", 'rev ok';

    is $doc->title => "foo", 'title ok';

    cmp_deeply $doc->author => { name => "foo" }, 'author ok';
    is $doc->author->name => "foo", 'author->name ok';

    cmp_deeply $doc->to_hash => {
        _id    => "foo",
        _rev   => "foo",
        title  => "foo",
        author => { name => "foo" },
    }, 'to_hash ok';
};

{ # read from hashref
    my $doc = CouchDB::Object::Document->new({
        _id    => "foo",
        _rev   => "foo",
        title  => "foo",
        author => { name => "foo" },
    });

    $tester->($doc);
}

{ # empty
    my $doc = CouchDB::Object::Document->new;
    $doc->id("foo");
    $doc->rev("foo");
    $doc->title("foo");
    $doc->author->name("foo");

    $tester->($doc);
}

{ # read from hash
    my $doc = CouchDB::Object::Document->new(
        id     => "foo",
        rev    => "foo",
        title  => "foo",
        author => { name => "foo" },
    );

    $tester->($doc);
}
