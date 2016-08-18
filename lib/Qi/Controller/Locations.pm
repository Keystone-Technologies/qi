package Qi::Controller::Locations;
use Mojo::Base 'Mojolicious::Controller';
use Qi::Model::Locations;

sub get {
  my $self = shift;
  my $json = $self->req->json; #this is optional. Not specifying an asset returns all assets
  $self->render(
    json => {
      table => 'locations', #repond with the table
      (($json) ? 'location' : 'locations') => $self->locations->select($json) #respond with a specified asset or all assets
    }
  );
}

1;