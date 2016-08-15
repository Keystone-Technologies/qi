package Qi::Controller::Assets;
use Mojo::Base 'Mojolicious::Controller';
use Qi::Model::Base;
use SQL::Abstract;

my $table = 'assets';

sub get {
  my $self = shift;
  my $response = $self->req->json;
  $self->stash('asset' => $self->base->select($response , $table));
  $self->render(json => $self->base->select($response, $table));
}

sub insert {
  my $self = shift;
  my $response = $self->req->json;
  $self->stash('asset' => $self->base->insert($response, $table));
  $self->render(json => $self->base->select($response, $table));
}

sub update {
  my $self = shift;
  my $response = $self->req->json;
  $self->stash('asset' => $self->base->update($response , $table));
  $self->render(json => $self->base->select($response, $table));
}

sub remove {
  my $self = shift;
  my $response = $self->req->json;
  $self->stash('asset' => $self->base->delete($response , $table));
  $self->render(json => $self->base->select($response, $table));
}

1;
