use 5.010;
use lib 'lib';
use Data::Dumper;
use QI::Schema;

die "Usage: $0 customer received price\n" unless $#ARGV==2;

my $qi = QI::Schema->connect('DBI:mysql:database=qi;host=localhost', '', '');

my $customers = $qi->resultset("Customers");
my $customer_id;
unless ( $ARGV[0] =~ /^\d+$/ ) {
	$customer_id = $customers->search({name=>$ARGV[0]})->first->customer_id;
}

my $assets = $qi->resultset("Assets");
my $last_tag = $assets->search({tag=>{like=>'%Z'}}, {order_by=>{-desc=>'tag'}})->first->tag;
my ($tag) = ($last_tag =~ /^(\d+)Z$/) or die "Cannot find last tag\n";
while ( <STDIN> ) {
	chomp;
	@_ = split /\t/;
	next unless $_[3] =~ /^\d+$/;
	$tag++;
	my $asset_type_id;
	given ( lc($_[5]) ) {
		when (/monitor/) { $asset_type_id = 13 }
		when (/lcd/) { $asset_type_id = 13 }
		when (/laptop/) { $asset_type_id = 11 }
		when (/tower/) { $asset_type_id = 4 }
		when (/printer/) { $asset_type_id = 30 }
		when (/server/) { $asset_type_id = 36 }
		when (/battery/) { $asset_type_id = 50 }
		when (/surge/) { $asset_type_id = 1 }
	}
	%_ = (
		tag => $tag.'Z',
		customer_tag => $_[3],
		customer_id => $customer_id,
		received => $ARGV[1],
		serial_number => $_[2],
		manufacturer => $_[0],
		model => $_[1],
		change_stamp => \'now()',
		add_stamp => \'now()',
		comments => join(' ; ', grep { $_ } @_[5..7]),
		asset_type_id => $asset_type_id,
	);
	if ( $_[6] =~ /bad|broken/i || $_[7] =~ /bad|broken/i ) {
		$_{location_id} = 7;
	} else {
		$_{sold_to} = 'Oklahoma';
		$_{sold} = \'now()';
		$_{price} = $ARGV[2];
	}
	$assets->create({%_});
	warn Dumper(\%_);
}
