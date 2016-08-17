package Qi::Model::Locations;
use Mojo::Base 'Qi::Model::Crud';

has table => 'locations';
has primary_key => 'location_id';