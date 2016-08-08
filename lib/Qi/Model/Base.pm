package Qi::Model::Base;
use strict;
use warnings;
use Mojo::Base 'Mojolicious';
has 'pg';

#### self Methods ####

sub select {
    my $self = shift;
 
    $self->pg->db->select($self->table_name, '*', @_)
}

sub insert {
    my $self = shift;
    my $db = $self->pg->db;
    $db->insert($self->table_name, @_)   or die $db->error();
    $db->last_insert_id('','','','')  or die $db->error();
}

sub update {
    my $self = shift;
    my $db = $self->pg->db;
    $db->update($self->table_name, @_) or die $db->error();
}

sub delete {
    my ($self, $asset_tag) = @_;
    warn Data::Dumper::Dumper($asset_tag->{asset_tag});
    my $db = $self->pg->db;
    my $results = eval {
        my $sql = 'delete from assets where tag = ?';
        $db->query($sql, $asset_tag->{asset_tag})
    }
    
}

1;