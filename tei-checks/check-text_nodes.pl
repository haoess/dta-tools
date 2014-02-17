#!/usr/bin/perl

=head1 NAME

check-text_nodes.pl -- Checks text nodes according to DTABf.
* @-Zeichen: darf nicht auftauchen
* #: sollte nicht auftauchen
* &\S: alle Stellen listen
* I in Frakturbüchern (d. h. außerhalb von <... rendition="#aq">) ist verdächtig
* ſ\s: alle Stellen listen (ganze Zeile als Kontext)
* ⁊ (U+204A): alle Stellen listen

=head1 INVOCATION

    $ perl check-text_nodes.pl $INFILE > $OUTFILE

=head1 VERSION

Version 0.01

=head1 SEE ALSO

L<http://www.deutschestextarchiv.de/doku/basisformat>.

=head1 AUTHOR

Arne Binder

=head1 LICENSE AND COPYRIGHT

    "THE BEER-WARE LICENSE" (Revision 42):
    
    <arne.b.binder@gmail> wrote this file. As long as you retain this notice you
    can do whatever you want with this stuff. If we meet some day, and you think
    this stuff is worth it, you can buy me a beer in return.

=cut

use warnings;
use strict;
use utf8;
use XML::Parser;

binmode( STDOUT, ':utf8' );
my $fh;
open($fh, '<:utf8', pop ) or die $!;
my $xml = do { local $/; <$fh> };
close $fh;

my $correct = 1;
my $ln = 0;
my @elements;
my $depth = -1;
my $inText = 0;

  my $p = new XML::Parser(Handlers => {Start => \&node_start,
                                     End   => \&node_end,
                                     Char  => \&node_char});
  $p->parse($xml);
  
  sub  node_start{
  	my ($p, $elem, %atts) = @_;
  	my $ln = $p->current_line;
  	my $pos = $p->current_column;
  	
	if($elem eq "text"){
		$inText = 1;
	}
  	if($atts{'rendition'}){
  		#merke die Tiefe, in der #aq das erste mal gesetzt wird...
  		if($atts{'rendition'}=~/#aq\b/s){
  			if($depth < 0){
				$depth = @elements;
			}
		}
  	}
  	push(@elements, $elem);
  }
  
  sub node_end{
  	my ($p, $elem) = @_;
  	my $lastElem = pop(@elements);
  	my $ln = $p->current_line;
	my $pos = $p->current_column;
  	if($lastElem ne $elem){
		print "hier ist was falsch! \@line: $ln current_element: $elem != stack_element: $lastElem\n";
	}else{
		if($elem eq "text"){
			$inText = 0;
		}
		#wenn #aq in der aktuellen Ebene das erste mal gesetzt wurde...
		if($depth==@elements){
			$depth = -1;
		}
	}
  }
  
  sub node_char{
    if($inText){
		my ($p, $str) = @_;
		my $pln = $p->current_line;
		my $ppos = $p->current_column +1;
		my @pcontext = split(/\n/,$p->position_in_context(0));
		my $context = shift(@pcontext);
		while($str =~ /(@|\#|&\S|ſ\s|\x{204a})/gs){
			my $realPos = length($`) + $ppos;			
			print "$1\t\@line: $pln \@pos: $realPos in:\t$context\n";
			$correct = 0;
		}	
		#außerhalb von #aq...
		if($depth < 0){ 
			while($str=~/\x{a7fe}/g){
				my $realPos = length($`) + $ppos;			
				print "I\t\@line: $pln \@pos: $realPos in:\t$context\n";
				$correct = 0;
			}
		}	
	}
  }

exit $correct;