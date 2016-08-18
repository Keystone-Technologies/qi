package Qi;
use warnings;
use Mojo::Base 'Mojolicious';
use Mojo::Pg;
use SQL::Abstract;

use Data::Dumper qw(Dumper);

# This method will run once at server start
sub startup {
  my $self = shift;

  #Config
  my $config = $self->plugin('Config');

  #Model
  $self->helper(pg => sub { state $pg = Mojo::Pg->new(shift->config('pg')) });
  #$self->helper(sql => sub{ state $sql = SQL::Abstract->new});
  $self->helper(assets => sub { state $assets = Qi::Model::Assets->new(pg => shift->pg) });
  $self->helper(locations => sub { state $locations = Qi::Model::Locations->new(pg => shift->pg) });

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  
  ######## API #########
  my $api = $r->under('/api');

  #Assets
  $api->get('/assets')->to('assets#get')->name('get_assets');       # get assets
  $api->post('/assets')->to('assets#insert')->name('post_asset');     # insert asset
  $api->put('/assets')->to('assets#update')->name('update_asset');     # update asset
  $api->delete('/assets')->to('assets#remove')->name('remove_asset'); # remove asset

  #Locations
  $api->get('/locations')->to('locations#get')->name('get_locations'); #get locations



  # Migrate to latest version if necessary
  my $path = $self->home->rel_file('migrations/qi.sql');
  $self->pg->migrations->name('qi')->from_file($path)->migrate;
}

1;
