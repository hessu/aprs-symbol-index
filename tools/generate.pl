#!/usr/bin/perl

eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;
use warnings;

use Text::CSV;
use YAML::Tiny;
use JSON;
use XML::Writer;
use IO::File;
use Data::Dumper;

my $src = 'symbols.csv';
my $out_dir = 'generated';

sub print_out($$)
{
	my($fn, $s) = @_;
	open(F, ">$fn") || die "Could not open $fn for writing: $!\n";
	print F $s;
	close(F) || die "Could not close $fn after writing: $!\n";
}

# main

warn "Reading and parsing CSV from $src ...\n";
my $csv = Text::CSV->new({
	binary => 1,
	sep_char => "\t",
	}) or die "Cannot use CSV: " . Text::CSV->error_diag();

my @rows;
open my $fh, "<:encoding(utf8)", $src or die "Failed to open $src for reading: $!";
my $line = 0;
while (my $row = $csv->getline($fh)) {
	$line++;
	
	next if ($line == 1);
	
	#$row->[2] =~ m/pattern/ or next; # 3rd field should match
	my($code, $tocall, $descr) = @{ $row };
	
	next if ($code eq '');
	
	# validation
	if ($code !~ /^[\/\\].$/) {
		die "Line $line: Invalid symbol code $code\n";
	}
	
	my $h = {
		'code' => $code,
		'tocall' => $tocall,
		'description' => $descr
	};
	
	if ($descr eq '') {
		$h->{'unused'} = 1;
		delete $h->{'description'};
	}
	
	push @rows, $h;
}
$csv->eof or $csv->error_diag();
close $fh;

#print Dumper(\@rows);


warn "Converting ...\n";

my $json_tree = {
	'symbols' => \@rows
};

print_out("$out_dir/symbols.dense.json", encode_json($json_tree));
print_out("$out_dir/symbols.pretty.json", to_json($json_tree, { pretty => 1 } ));
warn "   ... JSON done.\n";


# YAML
my $yaml = YAML::Tiny->new;
$yaml->[0]->{symbols} = \@rows;
$yaml->write("$out_dir/symbols.yaml");
warn "   ... YAML done.\n";

# XML
my $output = new IO::File(">$out_dir/symbols.xml");
my $xw = new XML::Writer(OUTPUT => $output);

$xw->startTag("symbols");

foreach my $c (@rows) {
	$xw->startTag("symbol");
	foreach my $k (keys %{ $c }) {
		$xw->startTag($k);
		$xw->characters($c->{$k});
		$xw->endTag($k);
	}
	$xw->endTag("symbol");
}
$xw->endTag("symbols");
$output->close();

warn "   ... XML done.\n";

