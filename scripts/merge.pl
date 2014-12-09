use 5.010;
use lib 'lib';
use Data::Dumper;
use QI::Schema;
my $old = QI::Schema->connect('DBI:mysql:database=qi_20130401;host=localhost', '', '');
my $new = QI::Schema->connect('DBI:mysql:database=qi;host=localhost', '', '');

my $old_assets = $old->resultset("Assets");
my $new_assets = $new->resultset("Assets");

my $n_rs = $new_assets->search({model=>'TEMPLATE'});
while ( my $n = $n_rs->next ) {
	my $o_rs = $old_assets->search({tag=>$n->tag});
	my $o = $o_rs->first;
	next unless defined $o;
	warn join("\t", (defined $o?$o->tag:''), "\t", $n->tag)."\n";
	%_ = ();
	foreach ( qw/parenttag customer_tag customer_id received serial_number asset_type_id manufacturer product model cond_id status_id hipaa hipaa_person sold_via_id sold billed paid customer_paid shipped price  related_expenses revenue_percentage comments add_stamp/ ) {
		$_{$_} = $o->$_;
	}
	$n->update({%_});
}

__END__
mysql [qi]> describe assets;
+--------------------+--------------+------+-----+---------------------+-----------------------------+
| Field              | Type         | Null | Key | Default             | Extra                       |
+--------------------+--------------+------+-----+---------------------+-----------------------------+
| tag                | varchar(7)   | NO   | PRI |                     |                             |
| parenttag          | varchar(7)   | YES  |     | NULL                |                             |
| customer_tag       | varchar(32)  | YES  |     | NULL                |                             |
| customer_id        | int(11)      | YES  |     | NULL                |                             |
| received           | date         | YES  |     | NULL                |                             |
| serial_number      | varchar(64)  | YES  |     | NULL                |                             |
| asset_type_id      | int(11)      | YES  |     | NULL                |                             |
| manufacturer       | varchar(255) | YES  |     | NULL                |                             |
| product            | varchar(255) | YES  |     | NULL                |                             |
| model              | varchar(255) | YES  |     | NULL                |                             |
| cond_id            | int(11)      | YES  |     | NULL                |                             |
| location_id        | int(11)      | YES  |     | NULL                |                             |
| qty                | int(11)      | YES  |     | 1                   |                             |
| status_id          | int(11)      | YES  |     | NULL                |                             |
| hipaa              | date         | YES  |     | NULL                |                             |
| hipaa_person       | int(11)      | YES  |     | NULL                |                             |
| sold_via_id        | int(11)      | YES  |     | NULL                |                             |
| buyer_id           | int(11)      | YES  |     | NULL                |                             |
| sold_to            | varchar(255) | YES  |     | NULL                |                             |
| po_number          | varchar(32)  | YES  |     | NULL                |                             |
| sold               | date         | YES  |     | NULL                |                             |
| billed             | date         | YES  |     | NULL                |                             |
| paid               | date         | YES  |     | NULL                |                             |
| customer_paid      | date         | YES  |     | NULL                |                             |
| shipped            | date         | YES  |     | NULL                |                             |
| price              | varchar(10)  | YES  |     | NULL                |                             |
| related_expenses   | varchar(10)  | YES  |     | NULL                |                             |
| revenue_percentage | varchar(10)  | YES  |     | NULL                |                             |
| comments           | varchar(512) | YES  |     | NULL                |                             |
| change_stamp       | timestamp    | NO   |     | CURRENT_TIMESTAMP   | on update CURRENT_TIMESTAMP |
| add_stamp          | timestamp    | NO   |     | 0000-00-00 00:00:00 |                             |
+--------------------+--------------+------+-----+---------------------+-----------------------------+
31 rows in set (0.01 sec)
