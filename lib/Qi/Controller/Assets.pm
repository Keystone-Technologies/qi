package Qi::Controller::Assets;
use Mojo::Base 'Mojolicious::Controller';
use Qi::Model::Assets;

sub get {
  my $self = shift;
  my $json = $self->req->json;
  $self->render(
    json => {
      table => 'assets',
      (($json) ? 'asset' : 'assets') => $self->assets->select($json)
    }
  );
}

sub insert {
  my $self = shift;
  warn $self->req->json;
  $self->render(
    json => {
      table => 'assets',
      tag => $self->assets->insert($self->req->json)
    }
  );
}

sub update {
  my $self = shift;
  my $json = $self->req->json;
  $self->render(
    json => {
      table => 'assets',
      status => $self->assets->update($json)
    }
  );
}

sub remove {
  my $self = shift;
  my $json = $self->req->json;
  $self->render(
    json => {
      table => 'assets',
      status => $self->assets->delete($json)
    }
  );
}

1;
