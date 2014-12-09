package QI::Schema::Result::Assets;
use base qw/DBIx::Class::Core/;
use Class::Method::Modifiers;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Helper::Row::ToJSON/);
__PACKAGE__->table('assets');
__PACKAGE__->add_columns(qw/tag parenttag customer_tag customer_id received serial_number asset_type_id manufacturer product model cond_id location_id qty status_id hipaa hipaa_person sold_via_id buyer_id sold_to po_number sold billed paid customer_paid shipped price related_expenses revenue_percentage comments change_stamp add_stamp/);
__PACKAGE__->set_primary_key('tag');
__PACKAGE__->belongs_to(customer => 'QI::Schema::Result::Customers', 'customer_id', {join_type=>'left'});
__PACKAGE__->belongs_to(asset_type => 'QI::Schema::Result::AssetTypes', 'asset_type_id', {join_type=>'left'});
__PACKAGE__->belongs_to(cond => 'QI::Schema::Result::Conds', 'cond_id', {join_type=>'left'});
__PACKAGE__->belongs_to(buyer => 'QI::Schema::Result::Buyers', 'buyer_id', {join_type=>'left'});
__PACKAGE__->belongs_to(location => 'QI::Schema::Result::Locations', 'location_id', {join_type=>'left'});
__PACKAGE__->belongs_to(sold_via => 'QI::Schema::Result::SoldVia', 'sold_via_id', {join_type=>'left'});
__PACKAGE__->belongs_to(status => 'QI::Schema::Result::Status', 'status_id', {join_type=>'left'});

use overload '""' => sub {shift->tag}, fallback => 1;

around 'customer' => sub {
	my $orig = shift;
	my $self = shift;
	if ( $_[0] ) {
		return $self->$orig($self->result_source->schema->resultset("Customers")->find({name=>$_[0]}));
	} else {
		return $self->$orig(@_);
	}
};


sub asset {
	my $self = shift;

	return 'tangible' if grep { defined $self->$_ } qw/customer_id customer_tag serial_number/;
	return 'quantifiable';
}

sub TO_JSON {
	my $self = shift;

	return {
		customer => $self->customer,
		asset_type => $self->asset_type,
		cond => $self->cond,
		buyer => $self->buyer,
		location => $self->location,
		sold_via => $self->sold_via,
		status => $self->status,
		asset => $self->asset,
		%{$self->next::method},
	}
}

1;
