use 5.010;
use lib 'lib';
use Data::Dumper;
use QI::Schema;
my $schema = QI::Schema->connect('DBI:mysql:database=qi;host=localhost', '', '');

my $assets = $schema->resultset("Assets");
while ( <> ) {
	warn join ', ', $., $_;
	chomp;
	my $tag = $_;
	for ( scalar $assets->search({tag=>$tag})->update({sold=>'2012-12-04 00:00:00'}) ) {
		when ( '0E0' ) { warn "No!\t$tag\n"; }
		default { warn "Ok!\t$tag\n"; }
	}
#	last;
}
