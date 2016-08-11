package Qi::Model::Base;
use strict;
use warnings;
use Mojo::Base 'Mojolicious';
use SQL::Abstract;

#### self Methods ####
has 'sql'; # $self->sql  for SQL::Abstract
has 'pg'; # $self->pg   for Mojo::Pg

sub select {
    my ($self, $response, $table) = @_;
    my($stmt, @bind) = $self->sql->select($table , '*');
    $self->pg->db->query($stmt, @bind);
}

sub insert {
    my ($self, $response, $table) = @_;
    my($stmt, @bind) = $self->sql->insert($table, $response);
    $self->pg->db->query($stmt, @bind);
}

sub update {
    my ($self, $response, $table) = @_;
    my($stmt, @bind) = $self->sql->update($table, $response->{data}, $response->{where});
    $self->pg->db->query($stmt, @bind);
}

sub delete {
    my ($self, $response , $table) = @_;
    my($stmt, @bind) = $self->sql->delete($table, $response);
    $self->pg->db->query($stmt, @bind);
}

1;