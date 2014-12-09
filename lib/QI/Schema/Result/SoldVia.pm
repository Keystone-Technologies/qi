package QI::Schema::Result::SoldVia;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table('sold_via');
__PACKAGE__->add_columns(qw/sold_via_id name/);
__PACKAGE__->set_primary_key('sold_via_id');
__PACKAGE__->has_many(assets => 'QI::Schema::Result::Assets', 'sold_via_id');

use overload '""' => sub {shift->name}, fallback => 1;

sub id { shift->sold_via_id }

1;
