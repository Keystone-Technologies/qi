package QI::Null;

sub new { bless {}, shift }
sub TO_JSON { {} }
sub AUTOLOAD { undef }

1;
