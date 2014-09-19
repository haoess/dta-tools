#!/usr/bin/perl

=head1 NAME

extract-meta.pl


=head1 INVOCATION

$ perl extract-meta.pl --file=<filename> --id=<id_book> --source=<source>

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
use Getopt::Long;
use File::Basename;
use List::Util qw/reduce/;
use utf8;

use constant EMPTY => "emptydummy";

binmode(STDOUT, ":utf8");

my %parameter;
my %data;
my @warnings;

$parameter{source} = 'dtae';

GetOptions(
    "id=i"     => \$parameter{id_book},
    "file=s"   => \$parameter{file},
    "source=s" => \$parameter{source},
) or die("Error in command line arguments\n");

die "no input file given\n" unless $parameter{file};
die "no id_book given\n" unless $parameter{id_book};

my $sql = SQL::Abstract->new();

my $parser = XML::LibXML->new(line_numbers => 1);

open( my $fh, '<:utf8', $parameter{file} ) or die $!;
my $xml = do { local $/; <$fh> };
close $fh;
my ( $header ) = $xml =~ /(<teiHeader>.*<\/teiHeader>)/s;
my $dom = $parser->parse_string( $header );

# set id
$data{id_book} = $parameter{id_book};

# get authors
my @authorNodes = getNodes('//teiHeader/fileDesc/titleStmt/author');
if (@authorNodes) {
	if (@authorNodes > 3){
		push @warnings, 'more than 3 authors found';
	}
	my $i = 0;
	while (@authorNodes) {
		$i++;
		my %authorData = getPersonData(shift(@authorNodes));
		if (exists $authorData{surname})  { $data{'autor'.$i.'_prename'} = qut($authorData{surname}) }
		if (exists $authorData{forename}) { $data{'autor'.$i.'_lastname'} = qut($authorData{forename}) }
		if (exists $authorData{addName})  { $data{'autor'.$i.'_syn_names'} = qut($authorData{addName}) }
		if (exists $authorData{pnd})      { $data{'autor'.$i.'_pnd'} = qut($authorData{pnd}) }
	}
}

# get translator
my @translatorNodes = getNodes('//teiHeader/fileDesc/sourceDesc/biblFull/titleStmt/editor[@role="translator"]');
if (@translatorNodes) {
	$data{uebersetzer} = qut(constructName(getPersonData($translatorNodes[0])));
}

# get publisher
my @publisherNodes = getNodes('//teiHeader/fileDesc/sourceDesc/biblFull/titleStmt/editor[not(@role="translator")]');
if (@publisherNodes) {
	$data{publisher} = qut(constructName(getPersonData($publisherNodes[0])));
}

$data{title} = qut(getContent('//teiHeader/fileDesc/titleStmt/title[@type="main"]'));
$data{subtitle} = qut(getContent('//teiHeader/fileDesc/titleStmt/title[@type="sub"]'));

$data{dta_pub_date} = getContent('//teiHeader/fileDesc/sourceDesc/biblFull/publicationStmt/date[@type="publication"]');
$data{dta_pub_location} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/publicationStmt/pubPlace'));
$data{dta_pub_verlag} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/publicationStmt/publisher/name'));

$data{dta_bibl_angabe} = qut(getContent('//teiHeader/fileDesc/sourceDesc/bibl'));

#TODO: put year in quotes? it's a string in the database...
$data{year} = getContent('//teiHeader/fileDesc/sourceDesc/biblFull/publicationStmt/date[@type="creation"]', $data{'dta_pub_date'});
$data{umfang} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/extent/measure[@type="pages"]'));
$data{umfang_normiert} = getContent('//teiHeader/fileDesc/extent/measure[@type="images"]');
#TODO: put band_alphanum in quotes? it's a string in the database...
$data{band_alphanum} = getContent('//teiHeader/fileDesc/titleStmt/title[@type="volume"]');
$data{band_zaehlung} = getAttributeValue('//teiHeader/fileDesc/titleStmt/title[@type="volume"]','n');

$data{dta_reihe_titel} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/seriesStmt/title[@type="main"]'));
$data{type} = getAttributeValue('//teiHeader/fileDesc/sourceDesc/bibl','type');
if ($data{type} =~ /^(MM|DS|MS|MMS)$/) {
	$data{dta_reihe_band} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/seriesStmt/biblScope[@unit="volume"]'));
}
else {
	$data{dta_reihe_jahrgang} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/seriesStmt/biblScope[@unit="volume"]'));
	$data{dta_reihe_band} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/seriesStmt/biblScope[@unit="issue"]'));
}
$data{type} = qut($data{type});

$data{dta_seiten} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/seriesStmt/biblScope[@unit="pages"]'));
$data{dta_comment2} = qut(getContent('//teiHeader/fileDesc/sourceDesc/biblFull/notesStmt/note'));

$data{ready} = qut(getContent(''));

$data{language} = getAttributeValue('//teiHeader/profileDesc/langUsage/language', 'ident', 'deu');
if ($data{language} ne 'deu') {
	push @warnings, 'language not german';
}

#$parameter{file} =~ m!/?([^\/]+?)\.!;
($parameter{dirname}) = basename($parameter{file}) =~ /(^[^\.]*)/;
$data{dirname} = qut($parameter{dirname});


$data{schriftart} = qut(getContent('//teiHeader/fileDesc/sourceDesc/msDesc/physDesc/typeDesc/p'));

#TODO: Priorität korrekt?
$data{prioritaet} = '1';
$data{planung} = qut('');
$data{startseite} = '0';

$data{genre} = qut(getContent('//teiHeader/profileDesc/textClass/classCode[@scheme="http://www.deutschestextarchiv.de/doku/klassifikation#dtamain"]','null'));
$data{untergenre} = qut(getContent('//teiHeader/profileDesc/textClass/classCode[@scheme="http://www.deutschestextarchiv.de/doku/klassifikation#dtasub"]','null'));
$data{dwds_kategorie1} = qut(getContent('//teiHeader/profileDesc/textClass/classCode[@scheme="http://www.deutschestextarchiv.de/doku/klassifikation#dwds1main"]'));
$data{dwds_unterkategorie1} = qut(getContent('//teiHeader/profileDesc/textClass/classCode[@scheme="http://www.deutschestextarchiv.de/doku/klassifikation#dwds1sub"]'));

$data{createdate} = `date +'%Y-%m-%d %H:%M:%S'`;
$data{createdate} =~ s/\n//g;

$data{source} = qut($parameter{source});


$data{resp} = '';
my @respStmts = getNodes('//teiHeader/fileDesc/titleStmt/respStmt');
while (@respStmts > 1) {
	$data{resp} .= shift(@respStmts)."\n";
}

my @editorialDecls = getNodes('//teiHeader/encodingDesc/editorialDecl');
if (@editorialDecls) {
	($data{txt}) = $editorialDecls[0] =~ /<editorialDecl>(.*)<\/editorialDecl>/s;
}

my @msIdentifiers = getNodes('//teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier');
if (@msIdentifiers) {
	$data{msidentifier} = $msIdentifiers[0];
}

my @licence = getNodes('//teiHeader/fileDesc/publicationStmt/availability/licence');
if (@licence) {
	$data{license} = $licence[0];
}

#DEBUG
#print "DATA:\n";
#printMap(%data);
#print "\n";

# construct SQL statements
$data{sql} = generateSqlInsert('book', 'id_book', 'title', 'subtitle', 'autor1_prename', 'autor1_lastname', 'autor1_syn_names', 'autor2_prename', 'autor2_lastname', 'autor2_syn_names', 'autor3_prename', 'autor3_lastname', 'autor3_syn_names', 'availability ', 'year', 'dta_pub_date', 'dta_pub_location', 'dta_pub_verlag','umfang', 'umfang_normiert', 'band_zaehlung', 'band_alphanum', 'autor1_pnd','autor2_pnd','autor3_pnd', 'dta_reihe_titel', 'dta_reihe_jahrgang', 'dta_reihe_band', 'dta_seiten', 'dta_bibl_angabe', 'ready', 'uebersetzer', 'dta_uebersetzer', 'publisher', 'dta_comment2');
$data{sql} = $data{sql}.";\n".generateSqlInsert('metadaten','id_book', 'genre', 'type', 'untergenre', 'dirname', 'schriftart', 'prioritaet', 'planung', 'startseite', 'dwds_kategorie1', 'dwds_unterkategorie1');
$data{sql} = $data{sql}.";\n".generateSqlInsert('sources','id_book', 'source');
$data{sql} = $data{sql}.";\n".'INSERT INTO open_tasks (id_book, id_task, createdate) SELECT '.$data{id_book}.', max(id_task) +1, '.qut($data{createdate}).' FROM open_tasks;';


if (not @warnings) {
	# could add warning...
	writeData('resp', 'txt', 'msidentifier', 'license', 'sql');
}

if (@warnings) {
	print "WARNINGS:\n";
	while(@warnings){
		print shift(@warnings)."\n";
	}
}
else {
	print $data{sql};
}



#########################
#       Functions       #
#########################

sub printMap {
	my (%map) = @_;
	if ( !keys %map ) {
		return;
	}
	foreach my $name (sort keys %map) {
		if ($map{$name} ne qut(EMPTY) and $map{$name} ne EMPTY) {
			printf "%-20s => %s\n", $name, $map{$name};
		}
    }
	print "\n";
}


sub getContent{
	my ($xpath) = @_;
	my $result = 'null';
	my @nodes;
	if (length($xpath) > 0) {
		@nodes= $dom->findnodes($xpath);
	}
	if (@nodes) {
		return cleanStr($nodes[0]->textContent);
	}
	if (@_ > 1) {
		return $_[1];
	}
	return EMPTY;
}

#unused
sub getNodeContent {
	my ($node) = @_;
	return cleanStr($node->textContent);
}

sub getAttributeValue{
	my ($xpath, $attribute) = @_;
	my $result = 'null';
	my @nodes;
	if (length($xpath) > 0) {
		@nodes= $dom->findnodes($xpath);
	}
	if (@nodes){
		return cleanStr($nodes[0]->getAttribute($attribute));
	}
	if( @_ > 2) {
		return $_[2];
	}
	return EMPTY;
}

sub getNodes{
	my ($xpath) = @_;
	my @nodes;
	if (length($xpath) > 0) {
		@nodes= $dom->findnodes($xpath);
	}
	return @nodes;
}

sub getPersonData{
	my ($node) = @_;

	my %personData;
	my @nodes;

	@nodes = $node->findnodes('.//roleName');
	if (@nodes) {
		push @warnings, 'roleName in personData';
	}
	@nodes = $node->findnodes('.//genName');
	if (@nodes) {
		push @warnings, 'genName in personData';
	}
	@nodes = $node->findnodes('.//nameLink');
	if (@nodes) {
		push @warnings, 'nameLink in personData';
	}

	@nodes = $node->findnodes('persName');
	if (@nodes) {
		my $temp = $nodes[0]->getAttribute('ref');
		if ($temp) {
			$temp =~ /.*\/(.+)$/;
			$personData{pnd} = cleanStr($1);
		}
	}
	@nodes = $node->findnodes('persName/surname');
	if (@nodes) {
		$personData{surname} = cleanStr($nodes[0]->textContent);
	}
	@nodes = $node->findnodes('persName/forename');
	if (@nodes) {
		$personData{forename} = cleanStr($nodes[0]->textContent);
	}
	@nodes = $node->findnodes('persName/addName');
	if (@nodes) {
		my $temp = cleanStr(shift(@nodes)->textContent);
		while (@nodes) {
			$temp .= '; '.shift(@nodes)->textContent;
		}
		$personData{addName} = $temp;
	}

	return %personData;
}

sub constructName{
	my (%personData) = @_;
	my $result = '';
	if (exists $personData{surname}) {
		$result = $personData{surname};
	}
	if (exists $personData{forename}) {
		if ($result ne '') {
			$result .= ', '.$personData{forename};
		}
        else{
			$result = $personData{forename};
		}
	}
	if (exists $personData{pnd}) {
		if ($result ne '') {
			$result .= ' #'.$personData{pnd};
		}
        else{
			$result = '#'.$personData{pnd};
		}
	}
	if (exists $personData{addName}) {
		if ($result ne '') {
			$result .= ' '.$personData{addName};
		}
        else {
			$result = $personData{addName};
		}
	}
	if ($result eq '') {
		return EMPTY;
	}
	return $result;
}

sub writeData {
	if (exists $parameter{dirname}) {
		while (@_) {
			my $dataIndex = shift;
			open(FILE, '>', $parameter{dirname}.'.'.$dataIndex) or die $!;
			binmode(FILE, ":utf8");
			print FILE $data{$dataIndex} or die $!;
			close FILE or die $!;
		}
	}
    else {
		push @warnings, "dirname not set.";
	}
}

sub qut {
	my ($s) = @_;
	if ($s ne 'null') {
		$s =~ s/\\/\\\\/g;
		$s =~ s/'/\\'/g;
		return q/'/.$s.q/'/;
	}
    else {
		return $s;
	}
}

sub cleanStr {
	my ($s) = @_;
	$s =~ s/^\s+|\s+$//g;
	my $number = () = $s =~ /\t/g;
	if ($number > 0) {
		# The only warning, which doesn't prevent to create the files/output, because the problem will be fixed. But be carefull while grabbing the output directly!
		printf '# WARNING: The string "'.$s.'" contains '.$number.' tab'.($number > 1?'s':'').'. '.($number > 1?'They':'It').' will be replaced by a single space.'."\n\n";
		$s =~ s/\t/ /g;
	}
	return $s;
}

sub generateSqlInsert {
	my ($table) = @_;
	my @table_fields = @_;
	my %table_data;

	foreach my $key (@table_fields) {
		if (exists $data{$key} and not ($data{$key} eq EMPTY or $data{$key} eq qut(EMPTY))) {
			$table_data{$key} = $data{$key};
		}
	}

	my ($stmt, @bind) = $sql->insert($table, \%table_data);
	$stmt =~ s/\([\?, ]*\)$//;
	{
		no warnings; # Keine Warnungen in diesem Block
		my $vals = reduce {$a.', '.$b} @bind;
		$stmt .= "(".$vals.")";
	}

	#return $sql->generate('INSERT INTO', \$table, \%table_data);
	return $stmt;
}

__DATA__
#TODO:
#	- elements not in example (mueller_hellenische02_1824)
#		- übersetzer ect.	DONE
#	- filedata:				DONE
#		- <respStmt>		$dirname.resp		DONE
#		- <editorialDecl>	$dirname.txt		DONE
#		- <availability xml:id="availability-textsource-1" corresp="#textsource-1">		$dirname.license								DONE
#		- <msIdentifier>	$dirname.msidentifier	DONE
#	- print files			DONE
#	- sql statements		DONE
#
#	- quoting
