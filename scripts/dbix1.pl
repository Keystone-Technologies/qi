use lib 'lib';
use Data::Dumper;
use QI::Schema;
use JSON::Any;
use JSON::XS;
my $json = JSON::XS->new;
my $schema = QI::Schema->connect('DBI:mysql:database=qi;host=localhost', '', '');

my $assets = $schema->resultset("Assets");
my $customers = $schema->resultset("Customers");
my $inventory = $schema->resultset("Inventory");

print $json->convert_blessed->encode([$assets->jsearch({'customer.name'=>'ASC'})]), "\n";
$_ = $assets->jsearch({'customer.name'=>'ASC'})->first;
print join(', ', $_->customer, $_->customer_id, $_->customer->name, $_->customer->id), "\n";
#print $_->customer($customers->find({name=>'Amdocs'})), "\n";
print $_->customer('Amdocs'), "\n";
print join(', ', $_->customer, $_->customer_id, $_->customer->name, $_->customer->id), "\n";
print $json->convert_blessed->encode([$inventory->jsearch({'location.name'=>'Above Server Room'})]), "\n";
print $inventory->jsearch({'location.name'=>'Above Server Room'})->first->location, "\n";
