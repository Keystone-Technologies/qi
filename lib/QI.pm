package QI;

sub warn_session {
	my $self = shift;
	no warnings;
	warn "------------------\n" unless $self->{__QI_WARN};
	warn join(' -=- ', ($_[0]||''), ++$self->{__QI_WARN}, 'who->'.$self->session->param('qi')->{who}, 'input->'.$self->query->param('input'), 'tag->'.($self->session->param('record')?$self->session->param('record')->tag:''), 'cell->'.$self->session->param('field').'='.(defined $self->session->param('value')?$self->session->param('value'):'NULL')), "\n";
}

sub who {
        my $self = shift;
        if ( $self->query->param('who') && $self->query->param('who') =~ $WHO ) {
                $self->warn_session("You tell me you're $1 and I trust you");
                $self->qi(who => $1);
                $self->qi(whotime => time);
        } elsif ( !$self->session->param('who') || time - $self->session->param('whotime') > 15 * 60 ) {
                $self->warn_session("Tell me who you are");
                return $self->qi(who => undef);
        } else {
                $self->warn_session("I know who you are");
                $self->qi(whotime => time);
        }
        return undef;
}

1;
