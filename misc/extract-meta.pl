#!/usr/bin/perl

=head1 NAME

extract-meta.pl


=head1 INVOCATION

$ perl extract-meta.pl $INFILE [id_book=$id_book]

=head1 VERSION

Version 0.01

=head1 SEE ALSO

L<http://www.deutschestextarchiv.de/doku/basisformat>.

=head1 AUTHOR

Arne Binder

=head1 LICENSE AND COPYRIGHT

This program is free software, you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that
modifications are open source. However, software that includes
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut

use 5.010;
use strict;
use warnings;
use XML::LibXML;
use SQL::Abstract;
use List::Util qw/reduce/;
use utf8;

my %parameter;
my %data;
my @warnings;
$parameter{path} = shift;
my $sql = SQL::Abstract->new();

use constant EMPTY => "emptydummy";

sub printMap{
	my (%map) = @_;
	if( !keys %map ){
		return;
	}
	
	foreach my $name (sort keys %map) {
		if($map{$name} ne qut(EMPTY) and $map{$name} ne EMPTY){
			printf "%-20s => %s\n", $name, $map{$name};
		}
    }
	
	print "\n";
}


while(@ARGV){
	my @temp = split('=',shift);
	
	if(@temp==2){
		$parameter{$temp[0]} = $temp[1];
	}
}

#DEBUG
#print "PARAMETER:\n";
#printMap(%parameter);

#my $id = pop;

my $parser = XML::LibXML->new(line_numbers => 1);
my $dom = $parser->parse_file($parameter{path});
my $root = $dom->documentElement;
my $xc = XML::LibXML::XPathContext->new( $root );
$xc->registerNs('tei', 'http://www.tei-c.org/ns/1.0');


sub getContent{
	my ($xpath) = @_;
	my $result = 'null';
	my @nodes;
	if(length($xpath) > 0){	
		@nodes= $dom->findnodes($xpath);
	}
	if(@nodes){
		$result = $nodes[0]->textContent;
		$result =~ s/^\s+|\s+$//g;
		return $result;
	}
	if(@_ > 1){
		shift;
		return(shift);
	}
	return EMPTY;
}

sub getNodeContent(){
	my ($node) = @_;
	my $result = $node->getContent;
	$result =~ s/^\s+|\s+$//g;
	return $result;
}

sub getAttributeValue{
	my ($xpath, $attribute) = @_;
	my $result = 'null';
	my @nodes;
	if(length($xpath) > 0){	
		@nodes= $dom->findnodes($xpath);
	}
	if(@nodes){
		$result = $nodes[0]->getAttribute($attribute);
		$result =~ s/^\s+|\s+$//g;
		return $result;
	}
	if(@_ > 2){
		shift;
		shift;
		return(shift);
	}
	return EMPTY;
}

sub getNodes{
	my $xpath = shift;
	my @nodes;
	if(length($xpath) > 0){	
		@nodes= $dom->findnodes($xpath);
	}
	return @nodes;
}

sub getPersonData{
	my $node = shift;
	
	my %personData;
	my @nodes;
	
	@nodes = $node->findnodes('.//roleName');
	if(@nodes){
		push(@warnings, 'roleName in personData');
	}
	@nodes = $node->findnodes('.//genName');
	if(@nodes){
		push(@warnings, 'genName in personData');
	}
	@nodes = $node->findnodes('.//nameLink');
	if(@nodes){
		push(@warnings, 'nameLink in personData');
	}
	
	@nodes = $node->findnodes('persName');
	if(@nodes){
		my $temp = $nodes[0]->getAttribute('ref');
		if($temp){
			$temp =~ /.*\/(.+)$/;
			$personData{pnd} = $1;
		}
	}
	@nodes = $node->findnodes('persName/surname');
	if(@nodes){
		$personData{surname} = $nodes[0]->textContent;
	}
	@nodes = $node->findnodes('persName/forename');
	if(@nodes){
		$personData{forename} = $nodes[0]->textContent;
	}
	@nodes = $node->findnodes('persName/addName');
	if(@nodes){
		my $temp = shift(@nodes)->textContent;
		while(@nodes){
			$temp = $temp.'; '.shift(@nodes)->textContent;
		}
		$personData{addName} = $temp;
	}
	
	return %personData;	
}

sub constructName{
	my (%personData) = @_;
	my $result = '';
	if(exists $personData{surname}){
		$result = $personData{surname};
	}
	if(exists $personData{forename}){
		if($result ne ''){
			$result = $result.', '.$personData{forename};
		}else{
			$result = $personData{forename};
		}
	}	
	if(exists $personData{pnd}){
		if($result ne ''){
			$result = $result.' #'.$personData{pnd};
		}else{
			$result = '#'.$personData{pnd};
		}
	}
	if(exists $personData{addName}){
		if($result ne ''){
			$result = $result.' '.$personData{addName};
		}else{
			$result = $personData{addName};
		}
	}
	if($result eq ''){
		return EMPTY;
	}
	return $result;	
}

sub writeData{
	if(exists $data{dirname}){
		while(@_){
			my $dataIndex = shift;
			open(FILE, '>'.unqut($data{dirname}).'.'.$dataIndex);
			print FILE $data{$dataIndex};
			close(FILE);
		}
	}else{
		push(@warnings, "dirname not set.")
	}	
}

sub qut{
	my $s = shift;
	if($s ne 'null'){
		$s =~ s/\\/\\\\/g;
		$s =~ s/'/\\'/g;
		return q/'/.$s.q/'/;
	}else{
		return $s;
	}
}

sub unqut{
	my $s = shift;
	if(length ($s) >= 2 and $s ne 'null'){
		$s =~ s/^'//;
		$s =~ s/'$//;
		$s =~ s/\\'/'/g;
		$s =~ s/\\\\/\\/g;
		return $s;
	}
	return $s;
}

sub generateSqlInsert{
	my $table = shift;
	my @table_fields = @_;
	my %table_data;
	#@table_data{@table_fields} = @data{ @table_fields };
	#my %table_data = map {$_=>$data{$_}} @table_fields;
	foreach my $key (@table_fields){
		if(exists $data{$key} and not ($data{$key} eq EMPTY or $data{$key} eq qut(EMPTY))){
			$table_data{$key} = $data{$key};
		}
	}
	my($stmt, @bind) = $sql->insert($table, \%table_data);
	$stmt =~ s/\([\?, ]*\)$//;
	{
		no warnings; # Keine Warnungen in diesem Block
		my $vals = reduce {$a.', '.$b} @bind;
		$stmt = $stmt."(".$vals.")";	
	}
	
	#$stmt =~ s/\)$//;
	#my $stmt_and_val = $sql->generate('INSERT INTO', \$table, \%table_data);
	return $stmt;
}



# set id
if(exists $parameter{id_book}){
	$data{id_book} = $parameter{id_book};
}

# get authors
my @authorNodes = getNodes('//teiHeader/fileDesc/titleStmt/author');
if(@authorNodes){
	if(@authorNodes > 3){
		push(@warnings, 'more than 3 authors found');
	}
	my $i = 0;
	while(@authorNodes){
		$i++;
		my %authorData = getPersonData(shift(@authorNodes));
		if(exists $authorData{surname}){ $data{'autor'.$i.'_prename'} = qut($authorData{surname});}
		if(exists $authorData{forename}){ $data{'autor'.$i.'_lastname'} = qut($authorData{forename});}
		if(exists $authorData{addName}){ $data{'autor'.$i.'_syn_names'} = qut($authorData{addName});}
		if(exists $authorData{pnd}){ $data{'autor'.$i.'_pnd'} = qut($authorData{pnd});}
	}	
}

# get translator
my @translatorNodes = getNodes('//teiHeader/fileDesc/sourceDesc/biblFull/titleStmt/editor[@role="translator"]');
if(@translatorNodes){
	$data{uebersetzer} = qut(constructName(getPersonData($translatorNodes[0])));
}

# get publisher
my @publisherNodes = getNodes('//teiHeader/fileDesc/sourceDesc/biblFull/titleStmt/editor[not(@role="translator")]');
if(@publisherNodes){
	$data{publisher} = qut(constructName(getPersonData($publisherNodes[0])));
}



$data{title} = qut(getContent('//teiHeader/fileDesc/titleStmt/title[@type="main"]'));
$data{subtitle} = qut(getContent('//teiHeader/fileDesc/titleStmt/title[@type="sub"]'));

$data{dta_pub_date} = getContent('//teiHeader/fileDesc/sourceDesc/biblFull/publicationStmt/date[@type="publication"]');
$data{dta_pub_location} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/publicationStmt/pubPlace'));
$data{dta_pub_verlag} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/publicationStmt/publisher/name'));

$data{dta_bibl_angabe} = qut(getContent('//teiHeader/fileDesc/sourceDesc/bibl'));

$data{year} = getContent('//teiHeader/fileDesc/sourceDesc/biblFull/publicationStmt/date[@type="creation"]', $data{'dta_pub_date'});
$data{umfang} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/extent/measure[@type="pages"]'));
$data{umfang_normiert} = getContent('//teiHeader/fileDesc/extent/measure[@type="images"]');

$data{band_alphanum} = getContent('//teiHeader/fileDesc/titleStmt/title[@type="volume"]'); 
$data{band_zaehlung} = getAttributeValue('//teiHeader/fileDesc/titleStmt/title[@type="volume"]','n'); 

#TODO: dta_reihe... correct?
$data{dta_reihe_titel} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/seriesStmt/title[@type="main"]'));
$data{dta_reihe_jahrgang} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/seriesStmt/biblScope[@unit="volume"]'));
$data{dta_reihe_band} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/seriesStmt/biblScope[@unit="issue"]'));
$data{dta_seiten} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/seriesStmt/biblScope[@unit="pages"]'));
$data{dta_comment2} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/notesStmt/note'));

$data{ready} = qut(getContent(''));

$data{language} = getAttributeValue('//teiHeader/profileDesc/langUsage/language', 'ident', 'deu');
if($data{language} ne 'deu'){
	push(@warnings, 'language not german');
}

$parameter{path} =~ m!/?([^\/]+?)\.!;
$data{dirname} = qut($1);

$data{type} = qut(getAttributeValue('//teiHeader/fileDesc/sourceDesc/bibl','type'));
$data{schriftart} = qut(getContent('//teiHeader/fileDesc/sourceDesc/msDesc/physDesc/typeDesc/p'));

#TODO: Priorität korrekt?
$data{prioritaet} = '1';
$data{planung} = qut('');
$data{startseite} = '0';

$data{genre} = qut(getContent('//teiHeader/profileDesc/textClass/classCode[@scheme="http://www.deutschestextarchiv.de/doku/klassifikation#dtamain"]','null'));
$data{untergenre} = qut(getContent('//teiHeader/profileDesc/textClass/classCode[@scheme="http://www.deutschestextarchiv.de/doku/klassifikation#dtasub"]','null'));
$data{dwds_kategorie1} = qut(getContent('//teiHeader/profileDesc/textClass/classCode[@scheme="http://www.deutschestextarchiv.de/doku/klassifikation#dwds1main"]'));
$data{dwds_unterkategorie1} = qut(getContent('//teiHeader/profileDesc/textClass/classCode[@scheme="http://www.deutschestextarchiv.de/doku/klassifikation#dwds1sub"]'));

$data{createdate} = `date +'%d-%m-%Y %H:%M:%S'`;
$data{createdate} =~ s/\n//g;


$data{resp} = '';
my @respStmts = getNodes('//teiHeader/fileDesc/titleStmt/respStmt');
while(@respStmts > 1){
	$data{resp} = $data{resp}.shift(@respStmts)."\n";
}

#TODO: just one editorialDecl??
my @editorialDecls = getNodes('//teiHeader/encodingDesc/editorialDecl');
if(@editorialDecls){
	$data{txt} = $editorialDecls[0];
}

#TODO: just one msIdentifier??
my @msIdentifiers = getNodes('//teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier');
if(@msIdentifiers){
	$data{msidentifier} = $msIdentifiers[0];
}

#TODO: all in <licence>?
my @licence = getNodes('//teiHeader/fileDesc/publicationStmt/availability/licence');
if(@licence){
	$data{license} = $licence[0];
}

#DEBUG
#print "DATA:\n";
#printMap(%data);
#print "\n";


$data{sql} = generateSqlInsert('book', 'id_book', 'title', 'subtitle', 'autor1_prename', 'autor1_lastname', 'autor1_syn_names', 'autor2_prename', 'autor2_lastname', 'autor2_syn_names', 'autor3_prename', 'autor3_lastname', 'autor3_syn_names', 'availability ', 'year', 'dta_pub_date', 'dta_pub_location', 'dta_pub_verlag','umfang', 'umfang_normiert', 'band_zaehlung', 'band_alphanum', 'autor1_pnd','autor2_pnd','autor3_pnd', 'dta_reihe_titel', 'dta_reihe_jahrgang', 'dta_reihe_band', 'dta_seiten', 'dta_bibl_angabe', 'ready', 'uebersetzer', 'dta_uebersetzer', 'publisher', 'dta_comment2');
$data{sql} = $data{sql}.";\n".generateSqlInsert('metadaten','id_book', 'genre', 'type', 'untergenre', 'dirname', 'schriftart', 'prioritaet', 'planung', 'startseite', 'dwds_kategorie1', 'dwds_unterkategorie1');
$data{sql} = $data{sql}.";\n".generateSqlInsert('sources','id_book', 'source'); 
$data{sql} = $data{sql}.";\n".'INSERT INTO open_tasks (id_book, id_task, createdate) SELECT '.$data{id_book}.', max(id_task) +1, '.qut($data{createdate}).' FROM open_tasks;';

#DEBUG
#print generateSqlInsert('book', 'id_book', 'title', 'subtitle', 'autor1_prename', 'autor1_lastname', 'prioritaet');


if(not @warnings){
	# could add warning...
	writeData('resp', 'txt', 'msidentifier', 'license', 'sql');	
}

if(@warnings){
	print "WARNINGS:\n";
	while(@warnings){
		print shift(@warnings)."\n";		
	}
}else{
	print $data{sql};	
}

__DATA__
#TODO:
#	- elements not in example (mueller_hellenische02_1824)
#		- übersetzer ect.
#	- filedata:				DONE
#		- <respStmt>		$dirname.resp	
#		- <editorialDecl>	$dirname.txt
#		- <availability xml:id="availability-textsource-1" corresp="#textsource-1">		$dirname.license
#		- <msIdentifier>	$dirname.msidentifier
#	- print files			DONE
#	- sql statements
