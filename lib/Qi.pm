package Qi;
use Mojo::Base 'Mojolicious';
use Mojo::Pg;

# This method will run once at server start
sub startup {
  my $self = shift;

  #Config
  my $config = $self->plugin('Config');

  #Helpers
  $self->helper(pg => sub { state $pg = Mojo::Pg->new(shift->config('pg')) });
  
  # Migrate to latest version if necessary
  my $path = $self->home->rel_file('migrations/qi.sql');
  $self->pg->migrations->name('qi')->from_file($path)->migrate;

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  $r->get('/asset')->to('assets#asset'); #returns information for a single asset
  $r->get('/table')->to('assets#table');
}

1;
