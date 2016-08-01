package Qi::Model::Assets;
use Mojo::Base - Base;

sub remove { #removes asset from database
    my ($self, $asset_tag) = @_; 
    my $results = eval {
        my $sql = 'delete from assets where tag = ?';
        $self->pg->db->query($sql, $asset_tag)->hash;
    }
}

1;
