package QI::Barcodes;

use strict;
use warnings;
no warnings qw(redefine);

use base 'QI::Base';

use Readonly;
use QI::Schema;
use GD::Barcode::Code39;
use Barcode::Code128;

sub barcodes_GET : Runmode {
	my $self = shift;

	%_ = ();
	my $c = 0;
	my $page = 0;

if ( my $pattern = $self->param('pattern') ) {
	$page++; $c=0;
	foreach my $tag ( sort { $a->comments cmp $b->comments } grep { $_->comments =~ qr/^($pattern)/i } $self->schema->resultset("BarcodeMap")->all ) {
		my $comments = $tag->comments || $tag->map || '';
		my $tag = sprintf("%06dY", $tag->id) || '';
		push @{$_{$page}}, qq[<div class="image"><img src="/pl/barcode/$tag" /><div class="text">$comments</div></div>\n];
#		push @_, qq[<div>$comments<br />$tag</div>\n];
	} continue { $page++ if ++$c%75==0 }
} else {
	# Old URL = http://www.barcodesinc.com/generator/image.php?code=$tag&style=197&type=C128B&width=200&height=50&xres=1&font=5
	$page++; $c=0;
if ( 0 ) {
	foreach my $tag ( sort { $a->comments cmp $b->comments } grep { $_->comments =~ /^Asset Type/i } $self->schema->resultset("BarcodeMap")->all ) {
		my $comments = $tag->comments || $tag->map || '';
		my $tag = sprintf("%06dY", $tag->id) || '';
		push @{$_{$page}}, qq[<div class="image"><img src="/pl/barcode/$tag" /><div class="text">$comments</div></div>\n];
#		push @_, qq[<div>$comments<br />$tag</div>\n];
	} continue { $page++ if ++$c%75==0 }
}
if ( 0 ) {
	$page++; $c=0;
	foreach my $tag ( sort { $a->comments cmp $b->comments } grep { $_->comments =~ qr/^(Color)/i } $self->schema->resultset("BarcodeMap")->all ) {
		my $comments = $tag->comments || $tag->map || '';
		my $tag = sprintf("%06dY", $tag->id) || '';
		push @{$_{$page}}, qq[<div class="image"><img src="/pl/barcode/$tag" /><div class="text">$comments</div></div>\n];
#		push @_, qq[<div>$comments<br />$tag</div>\n];
	} continue { $page++ if ++$c%75==0 }
}
if ( 0 ) {
	$page++; $c=0;
	foreach my $tag ( sort { $a->comments cmp $b->comments } grep { $_->comments =~ qr/^(Hipaa|Billed|Paid|Shipped|Sold :|Received)/i } $self->schema->resultset("BarcodeMap")->all ) {
		my $comments = $tag->comments || $tag->map || '';
		my $tag = sprintf("%06dY", $tag->id) || '';
		push @{$_{$page}}, qq[<div class="image"><img src="/pl/barcode/$tag" /><div class="text">$comments</div></div>\n];
#		push @_, qq[<div>$comments<br />$tag</div>\n];
	} continue { $page++ if ++$c%75==0 }
}
if ( 0 ) {
	$page++; $c=0;
	foreach my $tag ( sort { $a->comments cmp $b->comments } grep { $_->comments =~ qr/^(Value|Qty|Action|Received|Manu|Model|Product|Serial|Badge)/i } $self->schema->resultset("BarcodeMap")->all ) {
		my $comments = $tag->comments || $tag->map || '';
		my $tag = sprintf("%06dY", $tag->id) || '';
		push @{$_{$page}}, qq[<div class="image"><img src="/pl/barcode/$tag" /><div class="text">$comments</div></div>\n];
#		push @_, qq[<div>$comments<br />$tag</div>\n];
	} continue { $page++ if ++$c%75==0 }
	push @{$_{$page}}, qq[<div class="image"><img src="/pl/barcode/000000Z" /><div class="text">No Sticker</div></div>\n];
}
if ( 0 ) {
	$page++; $c=0;
	foreach my $tag ( sort { $a->comments cmp $b->comments } grep { $_->comments =~ qr/^(Customer)/i } $self->schema->resultset("BarcodeMap")->all ) {
		my $comments = $tag->comments || $tag->map || '';
		my $tag = sprintf("%06dY", $tag->id) || '';
		push @{$_{$page}}, qq[<div class="image"><img src="/pl/barcode/$tag" /><div class="text">$comments</div></div>\n];
#		push @_, qq[<div>$comments<br />$tag</div>\n];
	} continue { $page++ if ++$c%75==0 }
}
if ( 0 ) {
	$page++; $c=0;
	foreach my $tag ( sort { $a->comments cmp $b->comments } grep { $_->comments =~ qr/^(Location)/i } $self->schema->resultset("BarcodeMap")->all ) {
		my $comments = $tag->comments || $tag->map || '';
		my $tag = sprintf("%06dY", $tag->id) || '';
		push @{$_{$page}}, qq[<div class="image"><img src="/pl/barcode/$tag" /><div class="text">$comments</div></div>\n];
#		push @_, qq[<div>$comments<br />$tag</div>\n];
	} continue { $page++ if ++$c%75==0 }
}
}

	return qq[<style>\n.pb {page-break-after:always;-moz-column-count:5}\n.image {padding:20px 0px 0px 0px;border:1px black solid;position:relative;float:left;}\n.image .text {background-color:white;font-size:8px;font-family:Verdana;position:absolute;top:0px;left:10px;width:100%}\n</style>\n].
#	return qq[<style>\n.pb {page-break-after:always;-moz-column-count:3;border:1px black solid}\n.text {font-size:8px;font-family:Verdana;position:absolute;bottom:0px;right:0px;width:180px;}\n</style>\n].
		join('', map { qq[<div class="pb $_">\n].join('', @{$_{$_}}).qq[</div>\n] } sort {$a<=>$b} keys %_ );
}

sub barcode_GET : Runmode {
	my $self = shift;
	#my $barcode = $self->param('barcode');
	binmode(STDOUT);
	$self->header_add(-type => 'image/png');
	my $barcode = new Barcode::Code128;
	$barcode->font_align('center');
	#$barcode->height(25);
	$barcode->scale(1);
	$barcode->border(0);
	$barcode->transparent_text(1);
	print $barcode->png($self->param('barcode'));
#	return GD::Barcode::Code39->new(uc($barcode)||'*CODE39IMG*')->plot(Height=>50)->png;
}

1;
