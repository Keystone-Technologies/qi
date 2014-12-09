package QI::Schema::Result::Locations;
use base qw/DBIx::Class::Core/;
#use Class::Method::Modifiers;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table('locations');
__PACKAGE__->add_columns(qw/location_id name/);
__PACKAGE__->set_primary_key('location_id');
__PACKAGE__->has_many(assets => 'QI::Schema::Result::Assets', 'location_id');
__PACKAGE__->has_many(inventory => 'QI::Schema::Result::Inventory', 'location_id');

use overload '""' => sub {shift->name}, fallback => 1;

sub id { shift->location_id }

1;
