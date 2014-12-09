package QI::Schema::ResultSet::Inventory;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub jsearch {
	my ($self) = shift;
	my $search = shift || {};

	return $self->search($search, {prefetch=>[qw/asset_type location/],@_});
}

1;
