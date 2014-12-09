package QI::Dispatch;

use strict;
use warnings;

use base 'CGI::Application::Dispatch';

use Config::Auto;

sub dispatch_args {
	$ENV{CONFIG} ||= $ENV{QI_CONFIG};
	$ENV{CONFIG} or warn "[Dispatch] Environment CONFIG not defined\n";
	warn "[Dispatch] Loading config $ENV{CONFIG}...\n";
	$ENV{CONFIG} && -f $ENV{CONFIG} or warn "[Dispatch] Config file not found\n";
	my $config = Config::Auto::parse($ENV{CONFIG}) or warn "[Dispatch] Error parsing config\n";
	my $dispatch = $config->{DISPATCH} or warn "[Dispatch] DISPATCH not defined in config\n";

	if ( $dispatch->{debug} ) {
		use Data::Dumper;
		print STDERR '[Dispatch - env] '.Dumper(\%ENV);
		print STDERR '[Dispatch - config] '.Dumper($config);
	}

	return $dispatch || {};
}

1;
