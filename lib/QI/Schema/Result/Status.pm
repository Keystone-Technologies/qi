package QI::Schema::Result::Status;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table('status');
__PACKAGE__->add_columns(qw/status_id name/);
__PACKAGE__->set_primary_key('status_id');
__PACKAGE__->has_many(assets => 'QI::Schema::Result::Assets', 'status_id');

use overload '""' => sub {shift->name}, fallback => 1;

sub id { shift->status_id }

1;
