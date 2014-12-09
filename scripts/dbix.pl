use lib 'lib';
use Data::Dumper;
use QI::Schema;
use Mojo::JSON;

my $schema = QI::Schema->connect('DBI:mysql:database=qi;host=localhost', '', '');
print Mojo::JSON->new->encode($schema->resultset("Assets")->search({tag=>'001233A'})->first);
