package QI::Assets;

use strict;
use warnings;
no warnings qw(redefine uninitialized);

use base 'QI::Base';

use Readonly;
use Date::Manip;
use QI::Null;
use QI::Schema;
use Switch;
use List::Compare;
use Data::Dumper;
use Time::HiRes 'gettimeofday';

use constant WHOTIME => 15;
use constant {
	TANGIBLE => 1,
	QUANTIFIABLE => 2,
};

use vars qw/$TAG $TAGFIELD $MACRO $FIELD $VALUE $WANT $PROMPT $NOCOPY/;
#use vars qw/@WANT_HIPAA @WANT_TANGIBLE @NOCOPY_TANGIBLE/;

sub assets_POST : Runmode {
	my $self = shift;

$self->warn_session('Start');
	my @COLUMNS = $self->schema->source("Assets")->columns;
	my $VALID_FIELD = join '|', map { /(.*?)_id$/?($1,$_):$_ } @COLUMNS;
	$TAG = qr/^(\d{6}([A-Z]{1}))$/;
	$TAGFIELD = qr/^tag$|^parenttag$/;
	$MACRO = qr/^QIM_(\w+)(:([\w\s]*))?$/i;
	$FIELD = qr/^QIF_($VALID_FIELD)(:([\w\s]*))?$/i;
	$VALUE = qr/^QIV_(\w+)$/i;
	$WANT = {
		TANGIBLE => {
			PRIMARY => [qw/customer_id received customer_tag serial_number manufacturer product model asset_type_id location_id/],
			SECONDARY => {
				asset_type => {
					hipaa => [qw/Server Laptop Desktop/],
				},
				#sold => [qw/price related_expenses/],
				sold => [qw/price/],
			},
		},
		QUANTIFIABLE => {
			PRIMARY => [qw/product asset_type_id location_id/],
		},
	};
	$PROMPT = {
		TANGIBLE => {
			price => {skip => 0, label => 'Price:'},
			#related_expenses => {skip => 0, label => 'Related Expenses:'},
		},
		QUANTIFIABLE => {
			price => {skip => 0, label => 'Price:'},
			quantity => {skip => 1, label => 'Quantity:'},
		},
	};
	$NOCOPY = {
		TANGIBLE => {
			NON_PRIMARY => [List::Compare->new(\@COLUMNS, $WANT->{TANGIBLE}->{PRIMARY})->get_unique],
			UNLESS_EMPTY => [qw/customer_tag serial_number/],
		},
	};

	$self->process_input;

$self->warn_session('End');
	$self->json_xs->convert_blessed->encode({
#	warn Dumper([
		who => $self->who,
		record => $self->selected_record,
		prompt => $self->prompt,
		field => $self->selected_field,
		recent => $self->recent_records,
	});
}

##############################################################################

sub process_input {
	my $self = shift;
	return unless $self->query->param('input');
	my $input = $self->deflate_input($self->query->param('input'));
	$self->warn_session("Processing Input: $input");

	$self->selected_record;
	switch ( $input ) {
		case { $_[0] =~ $TAG } {
			# A non-Y tag
			$self->process_tag($input);
		}
		case { $_[0] =~ $MACRO } {
			# A deflated Y-tag
			$input =~ $MACRO;
			$self->process_macro($1 => $3);
		}
		case { $_[0] =~ $FIELD } {
			# A F/V pair
			$input =~ $FIELD;
			$self->process_value_and_update($1 => $3);
		}
		case { $_[0] !~ $TAG } {
			# Input is a field value and not a $TAG
			$self->process_value_and_update($self->selected_field => $input);
		}
		else {
			$self->warn_session("What kind of input is this?");
			$self->reset;
		}
	}
	# No need to return anything
}

sub deflate_input {
	my $self = shift;
	my $input = shift;
	return unless $input;
	$self->warn_session("Deflating Input: $input");

	$input =~ $TAG;
	switch ( $2 ) {
		case 'Y' {
			my $barcodemap = $self->barcodemap->find($input);
			$input = $barcodemap->map if ref $barcodemap;
		}
	}
	$self->warn_session("Deflated Input: $input");
	return $input;
}

sub process_tag {
	my $self = shift;
	my $tag = shift;
	return unless $tag;
	return if $self->selected_field =~ $TAGFIELD;	# Don't want to process input as a tag if the input field is expecting a tag as a value
	return if $self->selected_record($tag)->tag;		# If a tag is found, use it
	$self->warn_session("Processing Tag: $tag");

	$tag = $self->generate_tag if $tag eq '000000Z';
	if ( $self->selected_record->tag ) {
		if ( $self->detect_asset eq 'tangible' ) {
			$self->warn_session("Copying tangible asset to $tag");
			my @NOCOPY = @{$NOCOPY->{TANGIBLE}->{NON_PRIMARY}};
			foreach my $unless_empty ( @{$NOCOPY->{TANGIBLE}->{UNLESS_EMPTY}} ) {
				push @NOCOPY, $unless_empty if defined $self->selected_record->$unless_empty && $self->selected_record->$unless_empty;
			}
			$self->log;
			$self->selected_record->copy({add_stamp=>\'now()', tag => $tag, qty => 1, map { $_=>undef } grep { !/^tag$/ } @NOCOPY});
			$self->selected_record($tag);
			$self->clear;
		} elsif ( $self->detect_asset eq 'quantifiable' ) {
			$self->warn_session("Creating new quantifiable asset $tag");
			$self->log;
			$self->assets->create({add_stamp=>\'now()', tag => $tag, qty => 1});
			$self->selected_record($tag);
			$self->clear;
		} else {
			$self->warn_session("What kind of existing asset is this?");
		}
	} else {
		if ( $self->detect_asset eq 'tangible' ) {
			$self->warn_session("Creating new tangible asset $tag");
			$self->log;
			$self->assets->create({add_stamp=>\'now()', tag => $tag, qty => 1, received => UnixDate(ParseDate('now'), '%Y-%m-%d %H:%M:%S')});
			$self->selected_record($tag);
			$self->clear;
		} elsif ( $self->detect_asset eq 'quantifiable' ) {
			$self->warn_session("Creating new quantifiable asset $tag");
			$self->log;
			$self->assets->create({add_stamp=>\'now()', tag => $tag, qty => 1});
			$self->selected_record($tag);
			$self->clear;
		} else {
			$self->warn_session("What kind of new asset is this?");
		}
	}
}

sub process_macro {
	my $self = shift;
	my $key = shift;
	my $value = shift;
	return unless $key;
	$self->warn_session("Processing Macro");

	switch ( $key ) {
		case 'who' {
			$self->who($value);
		}
		case 'new_asset_type' {
			my $prompt = $self->query->param('prompt');
			my $asset_type = $self->asset_types->create({name=>$prompt});
			my $id = $asset_type->asset_type_id;
			$self->warn_session("$prompt - $id");
			$self->barcodemap->create({map=>"QIF_asset_type_id:$id",comments=>"Asset Type : $prompt"});
		}
		case 'new_customer' {
			my $prompt = $self->query->param('prompt');
			my $customer = $self->customers->create({name=>$prompt});
			my $id = $customer->customer_id;
			$self->warn_session("$prompt - $id");
			$self->barcodemap->create({map=>"QIF_customer_id:$id",comments=>"Customer : $prompt"});
		}
		case 'sell_now' {
			$self->process_value_and_update(
				location_id => $self->locations->find({name=>"Sold"})->id,
				sold => 'QIV_now',
			);
		}
		case 'green' {
			# NIB item
			$self->process_value_and_update(
				cond_id => $self->conds->find({name=>"NIB"})->id,
			);
		}
		case 'yellow' {
			# Refurb'd item
			$self->process_value_and_update(
				cond_id => $self->conds->find({name=>"Refurb'd / Tested"})->id,
			);
		}
		case 'red' {
			# As-is item
			$self->process_value_and_update(
				cond_id => $self->conds->find({name=>"Sell As-Is"})->id,
			);
		}
		case 'blue' {
			# Customer Cogent
			$self->process_value_and_update(
				customer_id => $self->customers->find({name=>"Cogent"})->id,
			);
		}
		case 'purple' {
			# Complete HIPAA process
			# Laptops, servers, desktops have HDDs...  The HDD must either not be included with the sale of the asset or the HDD must be wiped
			# HDDs, tapes... The HDD must be tagged and wiped
			# JS option prompt?: "Did you remove the media or did you DOD it?"
			$self->process_value_and_update(
				person => $self->who,
				hipaa => 'QIV_now',
			);
		}
		case 'delete' {
			$self->delete_record;
		}
		case 'reset' {
			$self->reset;
		}
		case 'cancel' {
			$self->clear;
		}
		case 'quantifiable' {
			$self->process_value_and_update(
				received => 'QIV_null',
				customer_id => 'QIV_null',
				customer_tag => 'QIV_null',
				serial_number => 'QIV_null',
				qty => 1,
			);
		}
		case 'tangible' {
			$self->process_value_and_update(
				received => 'QIV_now',
				customer_id => 9,
				qty => 'QIV_null',
			);
		}
		case 'start_batch' {
			# Prompt for Customer
			# Email Customer that we are starting this batch now()
			$self->batch(1);
			$self->reset;
		}
		case 'end_batch' {
			# Prompt for Customer
			# Email Customer that we are ending this batch now()
			$self->batch(0);
			$self->reset;
		}
	}

}

sub process_value_and_update {
	my $self = shift;
	my %pairs = @_;
	return unless $self->who;
	return unless $self->selected_record->tag;
	$self->warn_session("Processing Values");

	while ( my ($field, $value) = each %pairs ) {
		next unless $field;
		$self->selected_field($field) unless $field eq $self->selected_field;
		next unless defined $value;
		$self->warn_session("Processing Value and Updating: $field=$value");
		$value =~ $VALUE;
		switch ( $1 ) {
			#case 'tag' {
			#	($field, $tag) = ('tag', $value);
			#}
			case 'empty' {
				$value = '';
			}
			case 'null' {
				$value = "\0";
			}
			case 'now' {
				$value = UnixDate(ParseDate('now'), '%Y-%m-%d %H:%M:%S');
			}
			case 'skip' {
				$value = defined $self->selected_record->$field ? $self->selected_record->$field : $PROMPT->{uc($self->detect_asset)}->{$field}->{skip};
			}
			case /^plus\d+$/ {
				$1 =~ /^plus(\d+)$/;
				$value = ($self->selected_record->qty||0) + ($1||0);
			}
			case /^minus\d+$/ {
				$1 =~ /^minus(\d+)$/;
				$value = ($self->selected_record->qty||0) - ($1||0);
			} else {
				switch ( $value ) {
					case /^\+[\d\.]+$/ {
						$value =~ /^\+([\d\.]+)$/;
						$value = ($self->selected_record->$field||0) + ($1||0);
					}
					case /^\+\+$/ {
						$value = ($self->selected_record->$field||0) + 1;
					}
					case /^-[\d\.]+$/ {
						$value =~ /^-([\d\.]+)$/;
						$value = ($self->selected_record->$field||0) - ($1||0);
					}
					case /^--$/ {
						$value = ($self->selected_record->$field||0) - 1;
					}
				}
			}
		}
		$self->update_record($field, $value);
	}
}

sub delete_record {
	my $self = shift;
	return unless $self->who;
	return unless $self->selected_record->tag;
	$self->warn_session("Deleting Record");

	$self->selected_record->delete;
	#$self->selected_record->$field($value eq "\0" ? undef : $value)->update;
	#$self->selected_record->update;
	$self->log(field=>'( DELETE )');
	#$self->chain_update($field) if $value ne $previous;
	$self->reset;
}

sub update_record {
	my $self = shift;
	return unless $self->who;
	return unless $self->selected_record->tag;
	my $field = shift;
	my $value = shift;
	my $previous = $self->selected_record->$field;
	return unless $field && defined $value;
	$self->warn_session("Updating Record: $field = $previous --> $value");

	$self->selected_record->update({$field => $value eq "\0" ? undef : $value});
	#$self->selected_record->$field($value eq "\0" ? undef : $value)->update;
	#$self->selected_record->update;
	$self->log(field=>$field, previous=>$previous, value=>$value);
	$self->chain_update($field) if $value ne $previous;
	$self->clear;
}

sub chain_update {
	my $self = shift;
	my $field = shift;
	$self->warn_session("Chaining Updates from $field");

	switch ( $field ) {
		case 'manufacturer' {
			$self->process_value_and_update(
				product => 'QIV_null',
				model => 'QIV_null',
			);
		}
		case 'product' {
			$self->process_value_and_update(
				model => 'QIV_null',
			);
		}
	}
}

#####################################

sub who {
	my $self = shift;
	my $who = shift;

	if ( $who ) {
		$self->warn_session("You tell me you're $who and I trust you");
		$self->session->param(who => $who);
	} elsif ( !$self->session->param('who') || time - $self->session->param('whotime') > WHOTIME * 60 ) {
		$self->warn_session("Tell me who you are");
		$self->session->param(who => '');
	}
	$self->session->param(whotime => time);
	return $self->session->param('who');
}

sub batch {
	my $self = shift;
	return undef;
}

sub selected_record {
	my $self = shift;
	my $tag = shift;

	if ( $tag ) {
		if ( $self->assets->find({tag=>$tag}) ) {
			$self->warn_session("Selected record $tag for data entry");
			$self->session->param(tag => $tag);
			$self->clear;
		} else {
			return new QI::Null;
		}
	}
	return $self->assets->find({tag=>$self->session->param('tag')}) || new QI::Null;
}

sub selected_field {
	my $self = shift;
	my $field = shift;
	return undef unless $self->selected_record->tag;

	if ( $field ) {
		$self->warn_session("Selected field $field for data entry");
		$self->session->param(field => $field);
	} elsif ( !$self->session->param('field') ) {
		if ( $field = $self->next_field ) {
			$self->warn_session("Auto-selected field $field for data entry");
			$self->session->param(field => $field);
		}
	}		
	return $self->session->param('field');
}

sub next_field {
	my $self = shift;
	return unless $self->selected_record->tag;
	$self->warn_session("Looking up next default field");

	$self->clear;
	my @fields = @{$WANT->{uc($self->detect_asset)}->{PRIMARY}};
	if ( $WANT->{uc($self->detect_asset)}->{SECONDARY} ) {
		foreach my $basis ( keys %{$WANT->{uc($self->detect_asset)}->{SECONDARY}} ) {
			if ( ref $WANT->{uc($self->detect_asset)}->{SECONDARY}->{$basis} eq 'HASH' ) {
				foreach my $additional ( keys %{$WANT->{uc($self->detect_asset)}->{SECONDARY}->{$basis}} ) {
					push @fields, $additional if grep { $self->selected_record->$basis && $_ eq $self->selected_record->$basis } @{$WANT->{uc($self->detect_asset)}->{SECONDARY}->{$basis}->{$additional}};
				}
			} elsif ( ref $WANT->{uc($self->detect_asset)}->{SECONDARY}->{$basis} eq 'ARRAY' ) {
				foreach my $additional ( reverse @{$WANT->{uc($self->detect_asset)}->{SECONDARY}->{$basis}} ) {
					unshift @fields, $additional if $self->selected_record->$basis && not defined $self->selected_record->$additional;
				}
			}
		}
	}
	return ((grep { not defined $self->selected_record->$_ } @fields)[0]);
}

sub processed_value {
	my $self = shift;
	return unless $self->selected_field;
	my $value = shift;

	if ( $value ) {
		$self->warn_session("Deflated value $value for data entry");
		$self->session->param(value => $value);
	}
	return defined $self->session->param('value') ? $self->session->param('value') : '\0';
}

sub detect_asset {
	my $self = shift;

	return 'tangible' if $self->batch;
	return $self->selected_record->asset || 'quantifiable';
}

sub generate_tag {
	my $self = shift;

	my @tags = sort { $a <=> $b } map { $_->tag =~ /^(\d+)Z$/ } $self->assets->search({tag => {like => '%Z'}});
	@tags=('000000') if $#tags < 0;
	my $tag = sprintf("%06dZ", ++$tags[$#tags]);
	$self->warn_session("Generated $tag");
	return $tag;
}

sub prompt {
	my $self = shift;
	return undef unless $self->selected_record->tag;

	my $field = $self->selected_field;
	my $prompt = $field if grep { $_ eq $field } keys %{$PROMPT->{uc($self->detect_asset)}};
	if ( $prompt ) {
		$self->warn_session("Requesting prompt for $field");
		return $PROMPT->{uc($self->detect_asset)}->{$prompt}->{label};
	}
	return undef;
}

sub reset {
	my $self = shift;

	$self->clear;
	$self->session->clear(qw/tag field value/);
	return undef;
}

sub clear {
	my $self = shift;

	$self->query->delete([qw/input/]);
	$self->session->clear([qw/field value/]);
}

sub assets { shift->schema->resultset("Assets") }
sub customers { shift->schema->resultset("Customers") }
sub locations { shift->schema->resultset("Locations") }
sub asset_types { shift->schema->resultset("AssetTypes") }
sub status { shift->schema->resultset("Status") }
sub conds { shift->schema->resultset("Conds") }
sub barcodemap { shift->schema->resultset("BarcodeMap") }

sub recent_records {
	my $self = shift;
	my $rows = shift;
	return [] unless $self->who;
	return [] unless $self->assets;

	return [$self->assets->search(undef, {order_by=>{-desc=>'change_stamp'}, rows=>$rows||30})];
}

sub log {
	my $self = shift;
	$self->schema->resultset("Log")->create({who=>$self->who, tag=>$self->selected_record->tag||'', @_});
}

sub warn_session {
	my $self = shift;
	no warnings;
	$self->{__QI_TIME} = join '.', gettimeofday unless $self->{__QI_WARN};
	my $time = join '.', gettimeofday;
	warn "------------------".(scalar localtime)."\n" unless $self->{__QI_WARN};
	warn join(' -=- ', $time-$self->{__QI_TIME}, ($_[0]||''), ++$self->{__QI_WARN}, 'caller->'.((caller(2))[3]), 'who->'.$self->session->param('who'), 'input->'.$self->query->param('input'), 'tag->'.$self->session->param('tag')), "\n";
}

1;
