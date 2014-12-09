#!/bin/sh

# Location barcode map should never get modified because the locations have barcode affixed to them.

###echo 'delete from barcode_map where map like "QIF_location_id:%";';
#echo 'delete from barcode_map where map like "QIF_sold_via_id:%";';
#echo 'delete from barcode_map where map like "QIF_buyer_id:%";';
#echo 'delete from barcode_map where map like "QIF_customer_id:%";';
#echo 'delete from barcode_map where map like "QIF_status_id:%";';
echo 'delete from barcode_map where map like "QIF_asset_type_id:%";';
#echo 'delete from barcode_map where map like "QIM_who:%";';

echo 'alter table barcode_map auto_increment=1000;';

###echo 'insert into barcode_map (id,map,comments) select null,concat("QIF_location_id:",location_id),concat("Location : ",name) from locations;';
#echo 'insert into barcode_map (id,map,comments) select null,concat("QIF_sold_via_id:",sold_via_id),concat("Sold Via : ",name) from sold_via;';
#echo 'insert into barcode_map (id,map,comments) select null,concat("QIF_buyer_id:",buyer_id),concat("Buyer : ",name) from buyers;';
#echo 'insert into barcode_map (id,map,comments) select null,concat("QIF_customer_id:",customer_id),concat("Customer : ",name) from customers;';
#echo 'insert into barcode_map (id,map,comments) select null,concat("QIF_status_id:",status_id),concat("Status : ",name) from status;';
echo 'insert into barcode_map (id,map,comments) select null,concat("QIF_asset_type_id:",asset_type_id),concat("Asset Type : ",name) from asset_types;';
#echo 'insert into barcode_map (id,map,comments) select null,concat("QIM_who:",username),concat("Badge : ",name) from users;';

echo 'select * from barcode_map order by id;';
