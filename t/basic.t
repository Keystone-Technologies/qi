use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Qi');
$t->get_ok('/')->status_is(200);

$t = $t->post_ok('/asset' => {Accept =>'application/json'} => form => {'tag' => '000000A' , 'product' => 'PC'})
    ->status_is(200)
    ->json_has('/tag')
    ->json_has('/product');

my $tag = $t->tx->res->json('/tag');

$t->delete_ok('/asset' . $tag => {Accept => 'application/json'})->status_is(200)
    ->status_is(200)
    ->json_has('/tag')
    ->json_has('/product');

done_testing();
