package QI::Schema::Result::AssetTypes;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table('asset_types');
__PACKAGE__->add_columns(qw/asset_type_id name/);
__PACKAGE__->set_primary_key('asset_type_id');
__PACKAGE__->has_many(assets => 'QI::Schema::Result::Assets', 'asset_type_id');
__PACKAGE__->has_many(inventory => 'QI::Schema::Result::Inventory', 'asset_type_id');

use overload '""' => sub {shift->name}, fallback => 1;

sub id { shift->asset_type_id }

1;
