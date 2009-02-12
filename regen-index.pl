#!/usr/bin/perl
#use Data::Dumper;
use warnings;
use strict;
use lib ".";
use PatchIndexer;

# Regenerate the index to stdout

my ($FH, $index);
open $FH,'<',"0000_index.txt";
my @index = parseIndex($FH);
#print Dumper(@index);
print printIndex(\@index);
