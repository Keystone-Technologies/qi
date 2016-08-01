package Qi::Controller::Assets;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub asset {
    my $self = shift;
    
    my $tag = $self->param('tag');
    
    my $data->{response} = "You requested tag " . $tag;
    
    $self->render(json => $data);
}

sub table {
    my $self = shift;
    
    my $data->{response} = "you requested the table";
    
    $self->render(json => $data);
}

1;
