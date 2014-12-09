package QI::Schema::Result::Inventory;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Helper::Row::ToJSON/);
__PACKAGE__->table('inventory');
__PACKAGE__->add_columns(qw/tag parenttag name description asset_type_id equipment_condition unit_price comments change_stamp location_id qty/);
__PACKAGE__->set_primary_key('tag');
__PACKAGE__->belongs_to(asset_type => 'QI::Schema::Result::AssetTypes', 'asset_type_id', {join_type=>'left'});
__PACKAGE__->belongs_to(location => 'QI::Schema::Result::Locations', 'location_id', {join_type=>'left'});

use overload '""' => sub {shift->tag}, fallback => 1;

sub TO_JSON {
	my $self = shift;

	return {
		asset_type => $self->asset_type,
		location => $self->location,
		%{$self->next::method},
	}
}

1;
