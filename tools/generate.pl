#!/usr/bin/perl

# Debian/ubuntu dependencies:
# libyaml-tiny-perl libjson-perl libxml-writer-perl libxml-writer-perl

eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;
use warnings;

use YAML::Tiny;
use JSON;
use XML::Writer;
use IO::File;
use Data::Dumper;

my $src = 'symbols.yaml';
my $out_dir = 'generated';

sub print_out($$)
{
	my($fn, $s) = @_;
	open(F, ">$fn") || die "Could not open $fn for writing: $!\n";
	print F $s;
	close(F) || die "Could not close $fn after writing: $!\n";
}

sub check_entry($$$$$)
{
	my($name, $t, $optional, $mandatory, $classes) = @_;
	
	foreach my $r (keys %{ $t }) {
		die sprintf("'%s' has unknown  key '%s'\n", $name, $r)
			if (!defined $optional->{$r});
	}
	
	foreach my $r (keys %{ $mandatory }) {
		die sprintf("'%s' is missing key '%s'\n", $name, $r)
			if (!defined $t->{$r});
	}
	
	if (defined $t->{'class'} && !defined $classes->{ $t->{'class'} }) {
		die sprintf("'%s' has unknown class '%s'\n", $name, $t->{'class'});
	}
}


# main

warn "Reading and parsing YAML from $src ...\n";
my $yaml = YAML::Tiny->new;
my $c = YAML::Tiny->read($src);
if (!defined $c) {
	die "Failed to read in $src: " . YAML::Tiny->errstr . "\n";
}
warn "  ... parsed successfully.\n";

# get the first document of YAML
$c = $c->[0];

# validate main sections
die "Class definitions not found!\n" if (!defined $c->{'classes'});
die "Symbol definitions not found!\n" if (!defined $c->{'symbols'});
die "Overlay definitions not found!\n" if (!defined $c->{'overlays'});

# validate classes
my $count_class = 0;
my %class_keys = (
	'class' => 1,
	'shown' => 1,
	'description' => 1
);

my %classes;
foreach my $c (@{ $c->{'classes'} }) {
	$count_class++;
	foreach my $r (keys %class_keys) {
		die sprintf("Class '%s' is missing key '%s'\n", $c->{'class'}, $r)
			if (!defined $c->{$r});
	}
	foreach my $r (keys %{ $c }) {
		die sprintf("Class '%s' has unknown  key '%s'\n", $c->{'class'}, $r)
			if (!defined $class_keys{$r});
	}
	my $cid = $c->{'class'};
	delete $c->{'class'};
	$classes{$cid} = $c;
}
warn "  ... $count_class device classes found.\n";


# validate symbols
my %symbol_keys = (
	'code' => 1,
	'description' => 1,
	'tocall' => 1,
	'unused' => 1,
	'class' => 1,
);
my %symbol_keys_mandatory = (
	'code' => 1,
	'tocall' => 1,
);
my %overlay_keys_mandatory = (
	'code' => 1,
	'description' => 1,
);

my %symbols;
my $count_symbol = 0;
foreach my $t (@{ $c->{'symbols'} }) {
	$count_symbol++;
	check_entry($t->{'code'}, $t, \%symbol_keys, \%symbol_keys_mandatory, \%classes);
	
	my $code = $t->{'code'};
	delete $t->{'code'};
	$symbols{$code} = $t;
}
warn "  ... $count_symbol symbols found.\n";

my %overlays;
my $count_overlay = 0;
foreach my $t (@{ $c->{'overlays'} }) {
	$count_overlay++;
	check_entry($t->{'code'}, $t, \%symbol_keys, \%overlay_keys_mandatory, \%classes);
	
	my $code = $t->{'code'};
	delete $t->{'code'};
	$overlays{$code} = $t;
}
warn "  ... $count_overlay overlays / extended symbols found.\n";

warn "Converting ...\n";

my $json_tree = {
	'classes' => \%classes,
	'symbols' => \%symbols,
	'overlays' => \%overlays,
};

print_out("$out_dir/symbols.dense.json", encode_json($json_tree));
print_out("$out_dir/symbols.pretty.json", to_json($json_tree, { pretty => 1 } ));
warn "   ... JSON done.\n";


# XML
my $output = new IO::File(">$out_dir/symbols.xml");
my $xw = new XML::Writer(OUTPUT => $output);

$xw->startTag("aprs-symbol-index");

$xw->startTag("classes");
foreach my $c (sort keys %classes) {
	$xw->startTag("class", "id" => $c);
	foreach my $k (keys %{ $classes{$c} }) {
		$xw->startTag($k);
		$xw->characters($classes{$c}{$k});
		$xw->endTag($k);
	}
	$xw->endTag("class");
}
$xw->endTag("classes");

$xw->startTag("symbols");
foreach my $t (sort keys %symbols) {
	$xw->startTag("symbol");
	$xw->startTag("code");
	$xw->characters($t);
	$xw->endTag("code");
	foreach my $k (sort keys %{ $symbols{$t} }) {
		$xw->startTag($k);
		$xw->characters($symbols{$t}{$k});
		$xw->endTag($k);
	}
	$xw->endTag("symbol");
}
$xw->endTag("symbols");

$xw->endTag("aprs-symbol-index");

$xw->end();

warn "   ... XML done.\n";



exit 0;


