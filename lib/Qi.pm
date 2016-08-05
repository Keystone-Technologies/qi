package Qi;
use Mojo::Base 'Mojolicious';
use Mojo::Pg;

use Qi::Model::Assets;

# This method will run once at server start
sub startup {
  my $self = shift;
  
  $self->sessions->default_expiration(86400*365*10);

  #Config
  my $config = $self->plugin('Config');

  #Helpers
  $self->helper(pg => sub { state $pg = Mojo::Pg->new(shift->config('pg')) });
  $self->helper(assets => sub { state $assets = Qi::Model::Assets->new(pg => shift->pg) });
  
  
  $self->hook(around_action => sub {
    my ($next, $c, $action, $last) = @_;
    $c->session->{last_tag} ||= "000000A";

    return $next->();
  });
  
  # Migrate to latest version if necessary
  my $path = $self->home->rel_file('migrations/qi.sql');
  $self->pg->migrations->name('qi')->from_file($path)->migrate;

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  $r->get('/asset')->to('assets#asset'); #returns information for a single asset
  $r->get('/table')->to('assets#table');
  $r->get('/specialinputs')->to('assets#specialinputs');
  $r->get('/signout')->to('assets#signout'); #signs user out
  
  #this could use a better name
  $r->post('/mastercontroller')->to('assets#mastercontroller');
  
  $r->post('/asset')->to('assets#update'); #updates or creates an asset
}

1;
