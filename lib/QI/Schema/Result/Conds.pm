package QI::Schema::Result::Conds;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table('conds');
__PACKAGE__->add_columns(qw/cond_id name/);
__PACKAGE__->set_primary_key('cond_id');
__PACKAGE__->has_many(assets => 'QI::Schema::Result::Assets', 'cond_id');

use overload '""' => sub {shift->name}, fallback => 1;

sub id { shift->cond_id }

1;
