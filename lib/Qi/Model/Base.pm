package Qi::Model::Base;
use Mojo::Base -base;
use SQL::Abstract;
use Mojo::Collection;

has sql => sub { state $sql = SQL::Abstract->new };

#### self Methods ####
#has 'sql'; # $self->sql  for SQL::Abstract
has 'pg'; # $self->pg   for Mojo::Pg
has 'table' => sub {die "Forgot to define table"};


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
    my($stmt, @bind) = $self->sql->insert($self->table, $request, {returning => 'tag'}); #insert into $self->table $request 
    $self->pg->db->query($stmt, @bind)->hash->{tag}; #respond with tag
}

sub update {
    my ($self, $request) = @_;
    my($stmt, @bind) = $self->sql->update($self->table, $request->{data}, $request->{where}); #update $self->table set $request->{data} where $request->{where}
    $self->pg->db->query($stmt, @bind);
    return 'Success!'; # return success
}

sub delete {
    my ($self, $request) = @_;
    my($stmt, @bind) = $self->sql->delete($self->table, $request); #delete from $self->table where $request
    $self->pg->db->query($stmt, @bind); 
    return 'Success'; # return success
}

1;