package QI::Schema::Result::BarcodeMap;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Helper::Row::ToJSON/);
__PACKAGE__->table('barcode_map');
__PACKAGE__->add_columns(qw/id map comments/);
__PACKAGE__->set_primary_key('id');

use overload '""' => sub {shift->tag}, fallback => 1;

1;
