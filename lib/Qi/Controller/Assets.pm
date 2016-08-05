package Qi::Controller::Assets;
use Mojo::Base 'Mojolicious::Controller';

#probably should use a better name for this subroutine
sub update {
    my $self = shift;
    
    my $data->{results} = "probably ok";
    my $tag = $self->session->{last_tag};
    my $property = $self->param('property');
    my $value = $self->param('value');
    
    $data = eval {$self->pg->db->query('update assets set ' . $property . ' = ?, change_stamp = now() where tag = ?', $value, $tag)};    
    
    $self->render(json => $data);
}

#This subroutine could defintely be renamed
sub table {
    my $self = shift;
    
    my $data;
    
    #this query will be erplaced my a model call
    $data = $self->pg->db->query('select tag, parenttag, customer_id as customer, received, customer_tag, serial_number as serial, asset_type_id as asset_type, manufacturer, product, model, location_id as location from assets order by change_stamp desc limit 30;')->hashes->to_array;
    
    $self->render(json => $data);
}

sub specialinputs {
    my $self = shift;
    
    #this will be changed to be pulled from the database from the model probably
    #or maybe just stash this data when the page is loaded
    my $data->{tag} = "nochange";
    $data->{received} = "date";
    $data->{customer} = "select";
    $data->{asset_type} = "select";
    $data->{price} = "number";
    $data->{location} = "select";
    
    $self->render(json => $data);
}

#this should be renamed
sub mastercontroller {
    my $self = shift;
    
    my $tag = $self->param('tag');
    my $asset_open = $self->param('asset_open'); #true if the user has asset information displayed on his screen
    my $map = 0;
    my $data->{not_a_command} = 0; #the data to be sent back to the client
    
    #Checks if the tag has exactly 6 digits followed by a capital Y, if it does, goes in the if statement
    #  the ( ) in the expression is the selection, so anything found between the () will be extracted and placed into variable $1
    #  in this case, there will be exactly 6 digits in $1
    if($tag =~ m/(\d{6})Y/) {
        $map = eval {$self->pg->db->query('select map from barcode_map where id = ?', $1)->hash}; #move to a model
    }
    
    #not a good idea to have these macro letters defined in this if statement
    elsif($tag =~ m/^(\d{6})(A|B|Z)$/) {
        warn "OH BOY HERE BOY OH";
        # this here query will be removed when ben finishes his model creation
        # SO RIGHT NOT it is just sending it the id BUT this should be changed to run the id throught a function or something that will retreive the id from the table associated with it and send it the name instead
        #    so for example, we dont want to send customer_id = 12, instead send it customer = 'stevesteve' or something
        $data = eval {$self->pg->db->query('select tag, parenttag, customer_id as customer, received, customer_tag, serial_number, asset_type_id as asset_type, manufacturer, product, model, location_id as location from assets where tag like ?', $tag)->hash};
        if(!(defined $data)) {
            #then create a new one and let data be the new one
            #Wow this really truly is a terrible way to go about doing all these querys
            my $last_tag = eval {$self->pg->db->query("select received, customer_id, asset_type_id, manufacturer, product, model from assets where tag = ?", $self->session->{last_tag})->hash};
            $data = eval {$self->pg->db->query("insert into assets (tag, received, customer_id, asset_type_id, manufacturer, product, model, add_stamp) values (?, ?, ?, ?, ?, ?, ?, now());", $tag, $last_tag->{received}, $last_tag->{customer_id}, $last_tag->{asset_type_id}, $last_tag->{manufacturer}, $last_tag->{product}, $last_tag->{model})->hash};
            $data = eval {$self->pg->db->query('select tag, parenttag, customer_id as customer, received, customer_tag, serial_number, asset_type_id as asset_type, manufacturer, product, model, location_id as location from assets where tag like ?', $tag)->hash};
        }
        
        $data->{top_customers} = $self->pg->db->query('select name, customer_id as id from customers limit 4')->hashes->to_array;
        $data->{top_asset_types} = $self->pg->db->query('select name, asset_type_id as id from asset_types limit 4')->hashes->to_array;
        $data->{top_locations} = $self->pg->db->query('select name, location_id as id from locations limit 4')->hashes->to_array;
        
        $self->session->{last_tag} = $tag;
    }
    
    else {
        $data->{not_a_command} = 1;
    }
    
    if($map != undef) {
        $map = $map->{map};
    }
    
    #looking for qim, which is used to sign people in
    if($map =~ m/QIM/) {
        #Could simply return the name from the barcode map, but here it also checks the database to make sure the name that barcode map has is actually in the database
        if($map =~ m/_who:(.*)/) {
            $data->{name} = $self->pg->db->query('select username from users where username = ?', $1)->hash->{username}; #move to a model
            $self->session->{user} = $data->{name};
        }
    }
    if($map =~ m/QIF/) {
        if($map =~ m/_(.*):(.*)/) {
            if($asset_open eq "true") {
                #updates the asset according to the barcode map
                $self->pg->db->query('update assets set ' . $1 . ' = ?, change_stamp = now() where tag like ?', $2, $self->session->{last_tag});
                $data->{refresh} = 1;
                $data->{tag} = $self->session->{last_tag};
            }
        }
    }
    
    $self->render(json => $data);
}

sub signout {
    my $self = shift;
    
    $self->session(expires=>1);
    
    # Render template "example/welcome.html.ep" with message
    $self->redirect_to('/');
}

1;
