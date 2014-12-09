package QI::Schema::Result::Customers;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table('customers');
__PACKAGE__->add_columns(qw/customer_id name revenue_percentage/);
__PACKAGE__->set_primary_key('customer_id');
__PACKAGE__->has_many(assets => 'QI::Schema::Result::Assets', 'customer_id');

use overload '""' => sub {shift->name}, fallback => 1;

sub id { shift->customer_id }

1;
