package Qi::Model::Assets;
use Mojo::Base 'Qi::Model::Crud';

has table => 'assets';
has primary_key => 'tag';

#sub update_timestamp {
#    my ($self, $tag) = @_;
#    $self->sql
#    my $results = eval {
#        #my $sql = 'update ? set add_stamp= (now) where tag=?';
#        #$self->pg->db->query($sql, $self->table, $tag)->hash;
#        $self->update({data => {add_stamp => \'now()'}, where => {tag => $tag}})
#        
#    }
#    if ($@){ warn "there's an error";}
#    else {warn "Success!";}
#}
1;