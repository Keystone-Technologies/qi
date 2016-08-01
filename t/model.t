use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Mojo::Pg

$self->helper(pg => sub { state $pg = Mojo::Pg->new(shift->config('pg')) });


my $t = Test::Mojo->new('Qi');



done_testing();
