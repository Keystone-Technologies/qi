use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Qi');
$t->get_ok('/')->status_is(200);

$t = $t->post_ok('/api/assets' => {Accept =>'application/json' , dataType => 'json'} => json => {tag => '000000A' , add_stamp => '2016-08-10 16:21:21'})
    ->status_is(200);

$t = $t->put_ok('/api/assets' => {Accept =>'application/json' , dataType => 'json'} => json => { data => { tag => '000000B'} , where => {tag => '000000A'}})
    ->status_is(200);

$t = $t->get_ok('/api/assets' => {Accept =>'application/json'})->status_is(200);

$t->delete_ok('/api/assets' => {Accept => 'application/json' , dataType => 'json'} => json => {tag => '000000B'})
    ->status_is(200);
    



    


done_testing();
