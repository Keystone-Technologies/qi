package Qi::Controller::Assets;
use Mojo::Base 'Mojolicious::Controller';
use Qi::Model::Base;
use SQL::Abstract;

my $table = 'assets';

sub get {
  my $self = shift;
  my $response = $self->req->json;
  $self->stash('asset' => $self->base->select($response , $table));
  $self->respond_to(
    json => {json => $self->stash('asset')},
  );
}

sub insert {
  my $self = shift;
  my $response = $self->req->json;
  $self->stash('asset' => $self->base->insert($response, $table));
  $self->respond_to(
    json => {json => $self->stash('asset')},
  );
}

sub update {
  my $self = shift;
  my $response = $self->req->json;
  $self->stash('asset' => $self->base->update($response , $table));
  $self->respond_to(
    json => {json => $self->stash('asset')},
  );
}

sub remove {
  my $self = shift;
  my $response = $self->req->json;
  $self->stash('asset' => $self->base->delete($response , $table));
  $self->respond_to(
    json => {json => $self->stash('asset')},
  );
}

1;
