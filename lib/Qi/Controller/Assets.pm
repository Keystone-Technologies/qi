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
      tag => $self->assets->insert($self->req->json)->{tag}  #respond with the tag that was inserted
    }
  );
}

sub update {
  my $self = shift;
  my $json = $self->req->json;
  $self->render(
    json => {
      table => 'assets',
      tag => $self->assets->update($json)->{tag} #respond with tag of updated entry (if tag is updated, the new tag will be returned)
    }
  );
}

sub remove {
  my $self = shift;
  my $json = $self->req->json;
  $self->render(
    json => {
      table => 'assets',
      tag => $self->assets->delete($json)->{tag} #respond with tag that was deleted
    }
  );
}

1;
