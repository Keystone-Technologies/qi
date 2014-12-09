package QI::Schema::Result::Buyers;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table('buyers');
__PACKAGE__->add_columns(qw/buyer_id name/);
__PACKAGE__->set_primary_key('buyer_id');
__PACKAGE__->has_many(assets => 'QI::Schema::Result::Assets', 'buyer_id');

use overload '""' => sub {shift->name}, fallback => 1;

sub id { shift->buyer_id }

1;
