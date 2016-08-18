use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Qi');
$t->get_ok('/')->status_is(200);

$t = $t->post_ok('/api/assets' => {Accept =>'application/json' , dataType => 'json'} => json => {tag => '000000A' , add_stamp => '2016-08-10 16:21:21'})
    ->status_is(200)
    ->json_has({table => 'assets'})
    ->json_has({tag => '000000A'});

$t = $t->put_ok('/api/assets' => {Accept =>'application/json' , dataType => 'json'} => json => { data => { tag => '000000B'} , where => {tag => '000000A'}})
    ->status_is(200)
    ->json_has({table => 'assets'})
    ->json_has({tag => '000000B'});

$t = $t->get_ok('/api/assets' => {Accept =>'application/json'})
    ->status_is(200)
    ->json_has({table => 'assets'})
    ->json_has({'assets'});

$t->get_ok('/api/assets' => {Accept => 'application/json' , dataType => 'json'} => json => {tag => '000000B'})
    ->status_is(200)
    ->json_has({table => 'assets'})
    ->json_has({'asset'});

$t->delete_ok('/api/assets' => {Accept => 'application/json' , dataType => 'json'} => json => {tag => '000000B'})
    ->status_is(200)
    ->json_has({table => 'assets'})
    ->json_has({tag => '000000B'});

$t = $t->get_ok('/api/locations' => {Accept =>'application/json'})
    ->status_is(200)
    ->json_has({table => 'locations'})
    ->json_has({'locations'});

$t = $t->get_ok('/api/locations' => {Accept =>'application/json'})
    ->status_is(200)
    ->json_has({table => 'locations'})
    ->json_has({'locations'});





done_testing();
