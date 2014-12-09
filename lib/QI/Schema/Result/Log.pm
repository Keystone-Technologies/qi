package QI::Schema::Result::Log;
use base qw/DBIx::Class::Core/;
#use Class::Method::Modifiers;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Helper::Row::ToJSON/);
__PACKAGE__->table('log');
__PACKAGE__->add_columns(qw/id tag who field previous value stamp/);
__PACKAGE__->set_primary_key('id');

use overload '""' => sub {shift->id}, fallback => 1;

1;
