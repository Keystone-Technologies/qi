-- 1 up

CREATE TABLE if not exists asset_types (
  asset_type_id serial NOT NULL,
  name varchar(255) DEFAULT NULL,
  PRIMARY KEY ("asset_type_id")
);

CREATE TABLE if not exists assets (
  tag varchar(7) NOT NULL DEFAULT '',
  parenttag varchar(7) DEFAULT NULL,
  customer_tag varchar(32) DEFAULT NULL,
  customer_id int DEFAULT NULL,
  received date DEFAULT NULL,
  serial_number varchar(64) DEFAULT NULL,
  asset_type_id int DEFAULT NULL,
  manufacturer varchar(255) DEFAULT NULL,
  product varchar(255) DEFAULT NULL,
  model varchar(255) DEFAULT NULL,
  cond_id int DEFAULT NULL,
  location_id int DEFAULT NULL,
  qty int DEFAULT '1',
  status_id int DEFAULT NULL,
  hipaa date DEFAULT NULL,
  hipaa_person int DEFAULT NULL,
  sold_via_id int DEFAULT NULL,
  buyer_id int DEFAULT NULL,
  sold_to varchar(255) DEFAULT NULL,
  po_number varchar(32) DEFAULT NULL,
  listed date DEFAULT NULL,
  scrapped date DEFAULT NULL,
  sold date DEFAULT NULL,
  billed date DEFAULT NULL,
  paid date DEFAULT NULL,
  customer_paid date DEFAULT NULL,
  shipped date DEFAULT NULL,
  scrap_value varchar(10) DEFAULT NULL,
  price varchar(10) DEFAULT NULL,
  related_expenses varchar(10) DEFAULT NULL,
  revenue_percentage varchar(10) DEFAULT NULL,
  comments varchar(512) DEFAULT NULL,
  change_stamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  add_stamp timestamp NOT NULL
);

CREATE TABLE if not exists barcode_map (
  id serial NOT NULL,
  map varchar(255) DEFAULT NULL,
  comments varchar(255) DEFAULT NULL,
  PRIMARY KEY ("id")
);

CREATE TABLE if not exists buyers (
  buyer_id serial NOT NULL,
  name varchar(255) DEFAULT NULL,
  PRIMARY KEY ("buyer_id")
);

CREATE TABLE if not exists conds (
  cond_id serial NOT NULL,
  name varchar(255) DEFAULT NULL,
  PRIMARY KEY ("cond_id")
);

CREATE TABLE if not exists customers (
  customer_id serial NOT NULL,
  name varchar(255) DEFAULT NULL,
  revenue_percentage varchar(10) DEFAULT NULL,
  PRIMARY KEY ("customer_id")
);

CREATE TABLE if not exists locations (
  location_id serial NOT NULL,
  name varchar(255) DEFAULT NULL,
  label varchar(16) DEFAULT NULL,
  PRIMARY KEY ("location_id")
);

CREATE TABLE if not exists log (
  id serial NOT NULL,
  tag varchar(32) DEFAULT NULL,
  who varchar(255) DEFAULT NULL,
  field varchar(255) DEFAULT NULL,
  previous varchar(255) DEFAULT NULL,
  value varchar(255) DEFAULT NULL,
  stamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);

CREATE TABLE if not exists sessions (
  id char(32) NOT NULL,
  a_session text NOT NULL,
  PRIMARY KEY ("id")
);

CREATE TABLE if not exists sold_via (
  sold_via_id serial NOT NULL,
  name varchar(255) DEFAULT NULL,
  PRIMARY KEY ("sold_via_id")
);

CREATE TABLE if not exists status (
  status_id serial NOT NULL,
  name varchar(255) DEFAULT NULL,
  PRIMARY KEY ("status_id")
);

CREATE TABLE if not exists users (
  user_id serial NOT NULL,
  username varchar(32) DEFAULT NULL,
  name varchar(255) DEFAULT NULL,
  email varchar(255) DEFAULT NULL,
  PRIMARY KEY ("user_id")
);

DROP VIEW IF EXISTS asset_vw;

CREATE VIEW asset_vw AS 
  select 
    assets.tag AS tag,
    assets.parenttag AS parenttag,
    assets.received AS received,
    asset_types.name AS asset_type,
    assets.manufacturer AS manufacturer,
    left(assets.product,10) AS product,
    left(assets.model,10) AS model,
    locations.name AS location from (
      (
        assets left join asset_types 
        on(assets.asset_type_id = asset_types.asset_type_id)
      ) left join locations 
      on(assets.location_id = locations.location_id)
    )
;

-- 1 down

drop table if exists asset_types;
drop table if exists assets;
drop table if exists barcode_map;
drop table if exists buyers;
drop table if exists conds;
drop table if exists customers;
drop table if exists locations;
drop table if exists log;
drop table if exists sessions;
drop table if exists sold_via;
drop table if exists status;
drop table if exists users;
drop view if exists asset_vw;
