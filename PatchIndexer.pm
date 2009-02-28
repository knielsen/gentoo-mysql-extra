#!/usr/bin/perl
package PatchIndexer;
use Data::Dumper;
use Clone qw(clone);
use warnings;
use strict;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;
@ISA = qw(Exporter AutoLoader);
@EXPORT = qw( parseIndex printIndex selectPatches );

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
			storeEntry() if(length($patch) or length($comment));
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
			# Do not chomp descriptions
			$desc .= $1."\n";
		} elsif($i =~ /^#(.*)\s+$/) {
			# Do not chomp comments
			$comment .= $1."\n";
		} else {
			print "Bad! $i\n";
		}
	}
	storeEntry() if(length($patch) or length($comment));
	#print Dumper(@data);
	return @data;

	sub getEntry {
		my %entry;
		$entry{patch} = $patch if (length($patch) > 0);
		$entry{ver} = \@ver if (@ver);
		$entry{pn} = \@pn if (@pn);
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
		$os .= sprintf "\@patch %s\n", $i->{patch} if $i->{patch};
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
			$comment =~ s/^/#/gm;
			$os .= $comment."\n";
		}
		$os .= "\n";
	}
	chomp $os;
	return $os;
}

sub selectPatches {
	my (@index, $pn, $pv, @newindex);

	$_ = shift;
	@index = @{ $_ };

	$pn = shift;
	{ 
		$_ = shift;
		my @_pv = split /\./, $_;
		until($#_pv >= 3) { push @_pv, 0; };
		$pv = join('.', @_pv);
	}

	#printf "PN: %s\n", $pn;
	#printf "PV: %s\n", $pv;
	INDEX: foreach my $i (@index) {
		my ($match_pn, $match_pv);
		$match_pn = $match_pv = 0;
		TESTPN: foreach my $testpn ( @{ $i->{pn} } ) {
			#printf("testing pn='%s' against '%s' ", $pn, $testpn);
			if("$pn" eq "$testpn") {
				#printf("PASS\n");
				$match_pn = 1;
				last TESTPN;
			} else {
				#printf("FAIL\n");
			}
		}
		TESTPV: foreach my $testpv ( @{ $i->{ver} } ) {
			my @v = @$testpv;
			#printf("testing pv='%s' against '%s'-'%s' ", $pv, $v[0], $v[1]);
			if(pvGte($pv,$v[0]) and pvLte($pv,$v[1])) {
				#printf("PASS\n");
				$match_pv = 1;
				last TESTPV;
			} else {
				#printf("FAIL\n");
			}
		}
		# Special case for comments
		if(length($i->{comment})) {
			$match_pn = $match_pv = 1;
		}
		if($match_pn == 1 and $match_pv == 1) {
			#printf "match on %s\n", $i->{patch};
			push @newindex, $i;
		} else {
			#printf "no match on %s\n", $i->{patch};
		}
	}
	return @newindex;
}

sub pvCmp {
	my (@v1, @v2);
	@v1 = split(/\./, shift);
	@v2 = split(/\./, shift);
	for(my $i = 0; $i < 4; $i++) {
		if($v1[$i] > $v2[$i]) {
			return 1;
		} elsif($v1[$i] < $v2[$i]) {
			return -1;
		}
	}
	return 0;
}
sub pvGt {
	return pvCmp(shift, shift) > 0;
}
sub pvLt {
	return pvCmp(shift, shift) < 0;
}
sub pvGte {
	return pvCmp(shift, shift) >= 0;
}
sub pvLte {
	return pvCmp(shift, shift) <= 0;
}
