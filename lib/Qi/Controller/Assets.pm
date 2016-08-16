package Qi::Controller::Assets;
use Mojo::Base 'Mojolicious::Controller';
use Qi::Model::Assets;

sub get {
  my $self = shift;
  my $json = $self->req->json; #this is optional. Not specifying an asset returns all assets
  $self->render(
    json => {
      table => 'assets', #repond with the table
      (($json) ? 'asset' : 'assets') => $self->assets->select($json) #respond with a specified asset or all assets
    }
  );
}

sub insert {
  my $self = shift;
  $self->render(
    json => {
      table => 'assets',
      tag => $self->assets->insert($self->req->json)  #respond with the tag that was inserted
    }
  );
}

sub update {
  my $self = shift;
  my $json = $self->req->json;
  $self->render(
    json => {
      table => 'assets',
      status => $self->assets->update($json) #respond with 'Success' if successful
    }
  );
}

sub remove {
  my $self = shift;
  my $json = $self->req->json;
  $self->render(
    json => {
      table => 'assets',
      status => $self->assets->delete($json) #respond with 'Success' if successful
    }
  );
}

1;
