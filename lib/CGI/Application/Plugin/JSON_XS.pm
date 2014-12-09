package CGI::Application::Plugin::JSON_XS;

use warnings;
use strict;

use base 'Exporter';
our @EXPORT = qw[json_xs];

use JSON::XS;

sub json_xs {
	my $self = shift;

	$self->{__CAP_PLUGIN_JSON_XS} ||= JSON::XS->new;
	return $self->{__CAP_PLUGIN_JSON_XS};
}

1;
