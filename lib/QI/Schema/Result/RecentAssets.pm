package QI::Schema::Result::RecentAssets;
use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('assets');
__PACKAGE__->add_columns(qw/tag parenttag customer_tag customer_id received status_id customer_use_only serial_number asset_type_id manufacturer model equipment_condition sold_via_id buyer_id sold billed paid customer_paid shipped sale_price related_expenses revenue_percentage comments change_stamp location_id/);
__PACKAGE__->set_primary_key('tag');

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(q[
    SELECT * FROM assets WHERE YEAR(change_stamp) = YEAR(CURDATE()) AND MONTH(change_stamp) = MONTH(CURDATE()) ORDER BY change_stamp DESC LIMIT 30
]);

1;
