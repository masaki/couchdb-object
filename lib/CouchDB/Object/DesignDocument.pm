package CouchDB::Object::DesignDocument;

use Mouse;
use CouchDB::Object::Document;
use CouchDB::Object::View;

extends 'CouchDB::Object::Document';

has 'language' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'javascript',
);

has 'views' => (
    is         => 'rw',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [] },
);

sub name {
    my $self = shift;

    if (@_) {
        (my $name = shift) =~ s!_design/!!;
        $self->id("_design/${name}");
    }
    else {
        (my $name = $self->id) =~ s!_design/!!;
        return $name;
    }
}

sub BUILDARGS {
    my $class = shift;

    my $params = ref $_[0] eq 'HASH' ? shift : { @_ };

    my $args = {};
    for my $key (qw(id rev language)) {
        my $value = delete $params->{$key} || delete $params->{"_${key}"};
        $args->{$key} = $value if defined $value;
    }

    if (exists $params->{views} and ref $params->{views} eq 'HASH') {
        for my $name (sort keys %{ $params->{views} }) {
            my $functions = delete $params->{views}->{$name} || {};
            my $view = CouchDB::Object::View->new(name => $name, %$functions);
            push @{ $args->{views} }, $view;
        }
    }

    $args->{__fields} = Data::OpenStruct::Deep->new($params);

    return $args;
}

sub add_view {
    my ($self, $view) = @_;
    push @{ $self->views }, $view;
}

sub view {
    my ($self, $name) = @_;

    for my $view ($self->views) {
        return $view if $view->name eq $name;
    }

    return;
}

sub to_hash {
    my $self = shift;

    my $hash = { language => $self->language, views => {} };
    $hash->{_id}  = $self->id  if $self->has_id;
    $hash->{_rev} = $self->rev if $self->has_rev;

    for my $view ($self->views) {
        $hash->{views}->{$view->name} = { map => $view->map };
        if ($view->has_reduce) {
            $hash->{views}->{$view->name}->{reduce} = $view->reduce;
        }
    }

    return $hash;
}

no Mouse; __PACKAGE__->meta->make_immutable;
