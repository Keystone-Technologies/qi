package QI::Schema::ResultSet::Assets;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub jsearch {
	my ($self) = shift;
	my $search = shift || {};

	return $self->search($search, {join=>[qw/customer status/],prefetch=>[qw/customer status/],@_});
}

1;
