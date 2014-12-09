package QI::XLS;

use strict;
use warnings;

use base 'QI::Base';
use Spreadsheet::WriteExcel;
use QI::Schema;

sub qi_GET : Runmode {
	my $self = shift;
	$self->header_add(
		-type => 'application/vnd.ms-excel',
		-attachment => 'qi.xls',
	);
	open my $fh, '>', \my $str or die "Failed to open filehandle: $!";
	my $workbook = Spreadsheet::WriteExcel->new($fh);
	my $worksheet = $workbook->add_worksheet();
	my $assets = $self->schema->resultset("Assets");
	my $row=0;
	while ( my $asset = $assets->next ) {
		my %asset = $asset->get_columns;
		$worksheet->write($row, 0, [keys %asset]) unless $row;
		$worksheet->write($row++, 0, [values %asset]);
	}
	$workbook->close;
	close $fh;
	return $str;
}

sub amdocs_GET : Runmode {
	my $self = shift;
	$self->header_add(
		-type => 'application/vnd.ms-excel',
		-attachment => 'amdocs.xls',
	);
	open my $fh, '>', \my $str or die "Failed to open filehandle: $!";
	my $workbook = Spreadsheet::WriteExcel->new($fh);
	my $worksheet = $workbook->add_worksheet();
	my $assets = $self->schema->resultset("Assets")->search({customer_id=>'1'}, {order_by=>{-asc=>'received'}});;
	my $row=0;
	$worksheet->write($row++, 0, [map { $_ } qw/tag parenttag customer received customer_tag serial_number asset_type manufacturer product model cond sold price change_stamp/]);
	while ( my $asset = $assets->next ) {
		my %asset = $asset->get_columns;
		$worksheet->write($row, 0, [qw/tag parenttag customer received customer_tag serial_number asset_type manufacturer product model cond sold price change_stamp/]) unless $row;
		$worksheet->write($row++, 0, [map { $asset->$_ } qw/tag parenttag customer received customer_tag serial_number asset_type manufacturer product model cond sold price change_stamp/]);
	}
	$workbook->close;
	close $fh;
	return $str;
}

1;
