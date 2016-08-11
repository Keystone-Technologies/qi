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
  $self->helper(sql => sub{ state $sql = SQL::Abstract->new});
  $self->helper(base => sub { state $base = Qi::Model::Base->new(pg => shift->pg , sql => $self->sql) });

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  
  my $api = $r->under('/api');
  $api->get('/assets')->to('assets#get')->name('get');       # get assets
  $api->post('/assets')->to('assets#insert')->name('test');     # insert asset
  $api->put('/assets')->to('assets#update')->name('update');     # update asset
  $api->delete('/assets')->to('assets#remove')->name('remove'); # remove asset



  # Migrate to latest version if necessary
  my $path = $self->home->rel_file('migrations/qi.sql');
  $self->pg->migrations->name('qi')->from_file($path)->migrate;
}

1;
