package Qi::Controller::Assets;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub asset {
    my $self = shift;
    
    my $tag = $self->param('tag');
    
    #If the asset is in the database, return it as json. Otherwise, return a code signifying that a new asset needs to be created for that tag
    
    my $data->{response} = "You requested tag " . $tag;
    
    $self->render(json => $data);
}

#probably should use a better name for this subroutine
sub update {
    my $self = shift;
    
    my $data;
    
    $data->{tag} = $self->param('tag');
    $data->{customer} = $self->param('customer');
    $data->{asset_type} = $self->param('asset_type');
    
    #create new asset or update an existing one
    
    $data->{response} = "updating the information in the table, or creating a new entry HAH";
    
    $self->render(json => $data);
}

sub table {
    my $self = shift;
    
    my $data->{response} = "you requested the table";
    
    $self->render(json => $data);
}

1;
