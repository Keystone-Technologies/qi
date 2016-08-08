package Qi::Controller::Assets;
use Mojo::Base 'Mojolicious::Controller';
use Qi::Model::Base;
use Qi::Model::Assets;

sub remove {
  my $self = shift;
  my $asset_tag = $self->param('asset_tag');
  $self->stash('asset' => $self->assets->delete({asset_tag => $asset_tag}));
  $self->respond_to(
    json => {json => $self->stash('asset')},
  );
}

1;
