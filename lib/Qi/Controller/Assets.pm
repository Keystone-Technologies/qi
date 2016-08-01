package Qi::Controller::Assets;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework!');
}

sub remove {
  my $self = shift;
  my $asset_tag = $self->param('asset_tag');
  $self->stash('asset' => $self->assets->remove($asset_tag));
  $self->respond_to(
    json => {json => $self->stash('asset')},
  );
}

1;
