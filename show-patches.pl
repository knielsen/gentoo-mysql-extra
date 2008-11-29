#!/usr/bin/perl
use Getopt::Long;
use Data::Dumper;
use Clone qw(clone);
use warnings;
use strict;

my ($FH, $index);
open $FH,'<',"000_index.txt";
my @index = parseIndex($FH);
#print Dumper(@index);
printIndex(\@index);


sub parseIndex {
	my $fh = shift;
	our (@data, $patch, @ver, @pn, $desc, $comment);
	while(my $i = <$fh>) {
		#print "DATA: $i";
		if(0) {
			# These lines exists for patching only
			#
			#
		} elsif($i =~ /^\s*$/) {
			# Ignore whitespace
			#print "White: $i";
			getEntry();
			storeEntry() if(length($patch));
			#cleanEntry();
		} elsif($i =~ /^\@patch\s+(\S+)\s+$/) {
			cleanEntry();
			$patch = $1;
			chomp $patch;
		} elsif($i =~ /^\@ver\s+(\S+)\s+to\s+(\S+)\s+$/) {
			my $min = $1;
			my $max = $2;
			chomp $min;
			chomp $max;
			#print "Pushing ver $1 $2\n";
			push @ver, [$1,$2];
		} elsif($i =~ /^\@pn\s+(\S+)\s+$/) {
			my $mypn = $1;
			chomp $mypn;
			push @pn, $mypn;
		} elsif($i =~ /^\@\@\s+(.*)\s+$/) {
			# Do not chomp comments
			$desc .= $1."\n";
		} elsif($i =~ /^#\s+(.*)\s+$/) {
			# Do not chomp comments
			$comment .= $1."\n";
		} else {
			print "Bad! $i\n";
		}
	}
	storeEntry() if(length($patch));
	return @data;

	sub getEntry {
		my %entry;
		$entry{patch} = $patch;
		$entry{ver} = \@ver;
		$entry{pn} = \@pn;
		chomp $desc;
		$entry{desc} = $desc if (length($desc) > 0);
		chomp $comment;
		$entry{comment} = $comment if (length($comment) > 0);
		#print Dumper(\%entry);
		return %entry;
	}
	sub storeEntry {
		my %entry = getEntry();
		my $entry = clone(\%entry);
		#print Dumper(\%entry);
		push @data, $entry;
		cleanEntry();
	}
	sub cleanEntry {
			$patch = '';
			@ver = ();
			@pn = ();
			$desc = '';
			$comment = '';
	}
}

sub printIndex {
	$_ = shift;
	my @index = @{ $_ };
	my $os = '';
	foreach my $i (@index) {
		#print Dumper($i);
		$os .= sprintf "\@patch %s\n", $i->{patch};
		foreach $_ ( @{ $i->{ver} } ) {
			my @v = @$_;
			$os  .= sprintf "\@ver %s to %s\n", $v[0], $v[1];
		}
		foreach my $pn ( @{ $i->{pn} } ) {
			$os  .= sprintf "\@pn %s\n", $pn;
		}
		if($i->{desc}) {
			my $desc = $i->{desc};
			$desc =~ s/^/@@ /gm;
			$os .= $desc."\n";
		}
		if($i->{comment}) {
			my $comment = $i->{comment};
			$comment =~ s/^/# /gm;
			$os .= $comment."\n";
		}
		$os .= "\n";
	}
	print $os;
}
