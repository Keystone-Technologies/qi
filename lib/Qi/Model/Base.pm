package Qi::Model::Base;
use Mojo::Base -base;
use SQL::Abstract;
use Mojo::Collection;

has sql => sub { state $sql = SQL::Abstract->new };

#### self Methods ####
#has 'sql'; # $self->sql  for SQL::Abstract
has 'pg'; # $self->pg   for Mojo::Pg
has 'table' => sub {die "Forgot to define table"};


sub select {
    my ($self, $request) = @_;
    my($stmt, @bind) = $self->sql->select($self->table , '*', $request);
    if($request) {
        $self->pg->db->query($stmt, @bind)->hash;
    }
    else {
        $self->pg->db->query($stmt, @bind)->hashes;
    }
}

sub insert {
    my ($self, $request) = @_;
    my($stmt, @bind) = $self->sql->insert($self->table, $request, {returning => 'tag'});
    $self->pg->db->query($stmt, @bind)->hash->{tag};
}

sub update {
    my ($self, $request) = @_;
    my($stmt, @bind) = $self->sql->update($self->table, $request->{data}, $request->{where});
    $self->pg->db->query($stmt, @bind);
    return 'Success!';
}

sub delete {
    my ($self, $request) = @_;
    my($stmt, @bind) = $self->sql->delete($self->table, $request);
    $self->pg->db->query($stmt, @bind);
    return 'Success';
}

1;