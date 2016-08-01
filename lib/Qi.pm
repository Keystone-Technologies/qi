package Qi;
use Mojo::Base 'Mojolicious';
use Mojo::Pg;

# This method will run once at server start
sub startup {
  my $self = shift;

  #Config
  my $config = $self->plugin('Config');

  #Model
   $self->helper(pg => sub { state $pg = Mojo::Pg->new(shift->config('pg')) });

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');

  # Migrate to latest version if necessary
  my $path = $self->home->rel_file('migrations/Qi.sql');
  $self->pg->migrations->name('qi')->from_file($path)->migrate;
}

1;
