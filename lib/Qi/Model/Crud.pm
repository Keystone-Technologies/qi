package Qi::Model::Crud;
use Mojo::Base -base;
use SQL::Abstract;
use Mojo::Collection;

has sql => sub { state $sql = SQL::Abstract->new };

#### self Methods ####
#has 'sql'; # $self->sql  for SQL::Abstract
has 'pg'; # $self->pg   for Mojo::Pg
has 'table' => sub {die "Forgot to define table"};
has 'returning' => sub {die "Forgot to define returning"};


# **sql** is optional

sub select {
    my ($self, $request) = @_;
    my($stmt, @bind) = $self->sql->select($self->table , '*', $request); #select * from $self->table **where $request**
    if($request) { #if there is a where clause
        $self->pg->db->query($stmt, @bind)->hash; #respond with 1 row
    }
    else { #if no where clause
        $self->pg->db->query($stmt, @bind)->hashes; #respond with all rows
    }
}

sub insert {
    my ($self, $request) = @_;
    my($stmt, @bind) = $self->sql->insert($self->table, $request, {returning => $self->returning}); #insert into $self->table $request 
    $self->pg->db->query($stmt, @bind)->hash; #respond with primary key
}

sub update {
    my ($self, $request) = @_;
    my($stmt, @bind) = $self->sql->update($self->table, $request->{data}, $request->{where}, {returning => $self->returning}); #update $self->table set $request->{data} where $request->{where}
    $stmt = $stmt . ' returning ' . $self->returning;
    $self->pg->db->query($stmt, @bind)->hash;
}

sub delete {
    my ($self, $request) = @_;
    my($stmt, @bind) = $self->sql->delete($self->table, $request, {returning => $self->returning}); #delete from $self->table where $request
    warn $request;
    $stmt = $stmt . ' returning ' . $self->returning;
    warn $stmt;
    $self->pg->db->query($stmt, @bind)->hash;
}

1;