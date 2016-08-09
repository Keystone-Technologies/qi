package Qi;
use warnings;
use Mojo::Base 'Mojolicious';
use Mojo::Pg;


use Data::Dumper qw(Dumper);

# This method will run once at server start
sub startup {
  my $self = shift;

  #Config
  my $config = $self->plugin('Config');

  #Model
  $self->helper(pg => sub { state $pg = Mojo::Pg->new(shift->config('pg')) });
  $self->helper(assets => sub { state $assets = Qi::Model::Assets->new(pg => shift->pg) });
  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  
  my $api = $r->under('/api');
  
  $api->delete('/assets/:asset_tag')->to('assets#remove')->name('remove_asset');

  # Migrate to latest version if necessary
  my $path = $self->home->rel_file('migrations/qi.sql');
  $self->pg->migrations->name('qi')->from_file($path)->migrate;
}

1;
